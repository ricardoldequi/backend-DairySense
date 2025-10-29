class CioDetector
  def initialize(animal:, window_minutes: 10, z_threshold: 3.0, sustain_minutes: 40, since:)
    @animal = animal
    @window = window_minutes.to_i
    @window = 10 if @window <= 0
    @z_th = z_threshold.to_f
    @sustain = sustain_minutes.to_i # trocar o valor de sustain_minutes se quiser que o periodo de detecção seja menor ou maior
    @sustain = 30 if @sustain <= 0
    @since = since.in_time_zone
  end

  def call
    return unless @animal

    today = Time.zone.now
    links = DeviceAnimal.where(animal_id: @animal.id)
                        .where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", today, @since)
                        .order(:start_date)
    device_ids = links.pluck(:device_id).uniq
    return if device_ids.empty?

    # Conjuntos de períodos de baseline existentes para o animal
    periods = ActivityBaseline.where(animal_id: @animal.id)
                              .distinct
                              .pluck(:period_start, :period_end)

    # Para cada dia desde @since até hoje:
    (@since.to_date..today.to_date).each do |date|
      # pula dias cobertos por qualquer baseline (period_start a period_end)
      next if baseline_covers_date?(periods, date)

      process_day(device_ids, links, date)
    end
  end

  private

  def baseline_covers_date?(periods, date)
    periods.any? { |(ps, pe)| ps <= date && date <= pe }
  end

 def process_day(device_ids, links, date)
  from = date.in_time_zone.beginning_of_day
  to   = date.in_time_zone.end_of_day

  readings = Reading.where(device_id: device_ids, collected_at: from..to)
                    .order(:collected_at)
  return if readings.empty?

  step = @window.minutes

  # Agrupa o dia inteiro em janelas contínuas de @window, sem quebrar por hora
  by_window = readings.group_by { |r| floor_time(r.collected_at, step) }

  #  Constrói [timestamp_da_janela, mediana_ENMO, baseline_ref] por janela
  windows = by_window.keys.sort.map do |win_start|
    enmos = by_window[win_start].map { |r| enmo(r) }
    med   = median(enmos)

    # baseline por hora da janela atual
    hour  = win_start.in_time_zone.hour
    ref = ActivityBaseline.where(animal_id: @animal.id, hour_of_day: hour)
                          .where("period_end <= ?", date)
                          .order(period_end: :desc)
                          .first
    # se não houver baseline pra essa hora, pula a janela
    next unless ref

    [ win_start, med, ref ]
  end.compact

  return if windows.empty?

  detect_runs_and_alert(links, windows, step)
end

  def detect_runs_and_alert(links, windows, step = @window.minutes)
  eps = 1e-6
  run_minutes = 0
  run_start   = nil
  peak_z      = -Float::INFINITY
  prev_t      = nil

  #  tolerância de gap (ex: até 40 minutos sem leitura não quebra sequência)
  gap_tolerance = 40.minutes

  windows.each_with_index do |(t, med, ref), i|
    # quebra sequência apenas se o buraco for maior que o tolerado
    if prev_t && (t.to_i - prev_t.to_i) > (step + gap_tolerance)
      if run_minutes >= @sustain
        persist_alert(links, run_start, peak_z)
      end
      run_minutes = 0
      run_start   = nil
      peak_z      = -Float::INFINITY
    end

    denom = ref.mad_enmo.to_f.abs < eps ? eps : ref.mad_enmo.to_f
    z = (med - ref.baseline_enmo.to_f) / denom

    if z >= @z_th
      run_start ||= t
      run_minutes += @window
      peak_z = [ peak_z, z ].max
    else
      if run_minutes >= @sustain
        persist_alert(links, run_start, peak_z)
      end
      run_minutes = 0
      run_start   = nil
      peak_z      = -Float::INFINITY
    end

    prev_t = t

    # final da série
    if i == windows.size - 1 && run_minutes >= @sustain
      persist_alert(links, run_start, peak_z)
    end
  end
end


  def persist_alert(links, ts, z_peak)
    Rails.logger.info("[CioDetector] criando alert ts=#{ts} z_peak=#{z_peak}")

    return if Alert.for_animal(@animal.id)
                   .where(alert_type: "estrus")
                   .where(detected_at: (ts - 3.hours)..(ts + 3.hours))
                   .exists?

    # resolve device_animal_id pelo vínculo ativo na data do alerta
    link = links.select { |l| l.start_date.to_date <= ts.to_date && (l.end_date.nil? || l.end_date.to_date >= ts.to_date) }
                .max_by(&:start_date)
    return unless link
    # cria alerta
    Alert.create!(
      device_animal_id: link.id,
      alert_type: "estrus",
      detected_at: ts,
      z_score: z_peak
    )
  end

  def enmo(r)
    vm = Math.sqrt(r.accel_x.to_f**2 + r.accel_y.to_f**2 + r.accel_z.to_f**2)
    [ vm - 1.0, 0.0 ].max
  end

  def floor_time(t, step)
    tz_t = t.in_time_zone
    Time.zone.at((tz_t.to_i / step.to_i) * step.to_i)
  end

  def median(arr)
    a = arr.compact.sort
    n = a.size
    return 0.0 if n == 0
    n.odd? ? a[n / 2].to_f : (a[n / 2 - 1].to_f + a[n / 2].to_f) / 2.0
  end
end

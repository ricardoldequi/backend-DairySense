class BaselineCalculator
  def initialize(animal:, start_date:, end_date:, window_minutes: 10)
    @animal = animal
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    @window = window_minutes.to_i
    @window = 10 if @window <= 0
  end

  def call
    links = DeviceAnimal.where(animal_id: @animal.id)
                        .where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", @end_date, @start_date)

    (0..23).each do |hour|
      window_enmos = []

      links.each do |link|
        link_start = [ @start_date, link.start_date.to_date ].max
        link_end   = [ @end_date, (link.end_date || @end_date).to_date ].min
        next if link_end < link_start

        (link_start..link_end).each do |date|
          from = date.beginning_of_day + hour.hours
          to   = from + 1.hour

          rel = Reading.where(device_id: link.device_id, collected_at: from...to)
                       .order(:collected_at)

          rel.group_by { |r| floor_time(r.collected_at, @window.minutes) }.each_value do |group|
            enmos = group.map do |r|
              ax = r.accel_x.to_f; ay = r.accel_y.to_f; az = r.accel_z.to_f
              vm = Math.sqrt(ax*ax + ay*ay + az*az)
              [ vm - 1.0, 0.0 ].max
            end
            next if enmos.empty?
            window_enmos << median(enmos)
          end
        end
      end

      next if window_enmos.empty?
      med = median(window_enmos)
      mad_raw = mad(window_enmos, med)
      sigma_robust = 1.4826 * mad_raw

      ActivityBaseline.where(
        animal_id: @animal.id,
        hour_of_day: hour,
        period_start: @start_date,
        period_end: @end_date
      ).first_or_initialize.update!(
        baseline_enmo: med,
        mad_enmo: sigma_robust
        # window_minutes e variável de execução
      )
    end
  end

  private

  def floor_time(t, step)
    tz_t = t.in_time_zone
    Time.zone.at((tz_t.to_i / step.to_i) * step.to_i)
  end

  def median(arr)
    s = arr.sort
    n = s.length
    return nil if n == 0
    n.odd? ? s[n/2] : (s[n/2 - 1] + s[n/2]) / 2.0
  end

  def mad(values, med)
    return 0.0 if values.empty? || med.nil?
    median(values.map { |v| (v - med).abs }) || 0.0
  end
end

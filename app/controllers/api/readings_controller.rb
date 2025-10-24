module Api
  class ReadingsController < ApplicationController
    include Authenticable

    # POST /readings
    def create
      registros = params[:readings]
      return render json: { error: "Nenhum dado recebido" }, status: :bad_request if registros.blank?

      device = current_device
      return render json: { error: "Dispositivo não autenticado" }, status: :unauthorized unless device

      readings = []
      avisos = []

      registros.each_with_index do |r, idx|
        collected_at = r["collected_at"].present? ? Time.zone.parse(r["collected_at"]) : Time.zone.now

        # tenta vinculo ativo para o horário
        device_animal = DeviceAnimal.where(device_id: device.id)
                                    .where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", collected_at, collected_at)
                                    .order(start_date: :desc)
                                    .first
        # fallback: usa o vínculo mais recente do device
        device_animal ||= DeviceAnimal.where(device_id: device.id).order(start_date: :desc).first

        if device_animal.nil?
          avisos << { index: idx, mensagem: "Sem vínculo de animal para o dispositivo" }
          next
        end

        readings << device.readings.build(
          animal_id:  device_animal.animal_id,
          latitude:   r["latitude"],
          longitude:  r["longitude"],
          accel_x:    r["accel_x"],
          accel_y:    r["accel_y"],
          accel_z:    r["accel_z"],
          collected_at: collected_at
        )
      end

      return render json: { error: "Nenhuma leitura válida", avisos: avisos }, status: :unprocessable_content if readings.empty?

      result = Reading.import(readings)
      if result.failed_instances.any?
        render json: { error: "Falha ao salvar algumas leituras", detalhes: result.failed_instances, avisos: avisos }, status: :internal_server_error
      else
        render json: { message: "#{readings.size} leituras salvas", avisos: avisos.presence }, status: :created
      end
    rescue => e
      render json: { error: "Erro ao salvar leituras", detalhes: e.message }, status: :internal_server_error
    end
  end
end
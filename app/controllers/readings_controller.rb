class ReadingsController < ApplicationController
    include Authenticable

  # POST /readings
  def create
  registros = params["readings"]

    if registros.blank?
      render json: { error: "Nenhum dado recebido" }, status: :bad_request
      return
    end

    readings = registros.map do |r|
      Reading.new(
        device_id: current_device.id,
        animal_id: r["animal_id"],
        temperature: r["temperature"],
        sleep_time: r["sleep_time"],
        latitude: r["latitude"],
        longitude: r["longitude"],
        accel_x: r["accel_x"],
        accel_y: r["accel_y"],
        accel_z: r["accel_z"],
        collected_at: r["collected_at"]
      )
    end

    begin
      result = Reading.import(readings)
      if result.failed_instances.any?
        render json: { error: "Falha ao salvar algumas leituras", detalhes: result.failed_instances }, status: :internal_server_error
      else
        render json: { message: "#{result.num_inserts} leituras salvas com sucesso" }, status: :created
      end
    rescue => e
      render json: { error: "Erro ao salvar leituras", detalhes: e.message }, status: :internal_server_error
    end
  end
end

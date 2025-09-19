class ReadingsController < ApplicationController
    include Authenticable

  # POST /readings
  def create
    registros = params["readings"]

    if registros.blank?
      render json: { error: "Nenhum dado recebido" }, status: :bad_request
      return
    end

    device = current_device
    if device.nil?
      render json: { error: "Dispositivo não autenticado" }, status: :unauthorized
      return
    end

      readings = []
      erros = []
      registros.each_with_index do |r, idx|
        collected_at = r["collected_at"] ? Time.parse(r["collected_at"]).in_time_zone("America/Sao_Paulo") : Time.current.in_time_zone("America/Sao_Paulo")
        device_animal = DeviceAnimal.where(device_id: device.id)
          .where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", collected_at, collected_at)
          .order(start_date: :desc)
          .first
        if device_animal.nil?
          erros << { index: idx, mensagem: "Nenhum período cadastrado para a leitura em #{collected_at}" }
          next
        end
        readings << Reading.new(
          device_id: device.id,
          animal_id: device_animal.animal_id,
          temperature: r["temperature"],
          sleep_time: r["sleep_time"],
          latitude: r["latitude"],
          longitude: r["longitude"],
          accel_x: r["accel_x"],
          accel_y: r["accel_y"],
          accel_z: r["accel_z"],
          collected_at: collected_at
        )
      end

      if readings.empty?
        render json: { error: "Nenhuma leitura salva", detalhes: erros }, status: :unprocessable_entity
        return
      end

      begin
        result = Reading.import(readings)
        resposta = { message: "#{result.num_inserts} leituras salvas com sucesso" }
        resposta[:leituras_ignoradas] = erros unless erros.empty?
        if result.failed_instances.any?
          render json: { error: "Falha ao salvar algumas leituras", detalhes: result.failed_instances, ignoradas: erros }, status: :internal_server_error
          return
        else
          render json: resposta, status: :created
          return
        end
      rescue => e
        render json: { error: "Erro ao salvar leituras", detalhes: e.message, ignoradas: erros }, status: :internal_server_error
        return
      end

    begin
      result = Reading.import(readings)
      if result.failed_instances.any?
        render json: { error: "Falha ao salvar algumas leituras", detalhes: result.failed_instances }, status: :internal_server_error
      else
        render json: { message: "#{result.num_inserts} leituras salvas com sucesso" }, status: :created
      end
    rescue => e
      render json: { error: "Erro ao salvar leituras
      ", detalhes: e.message }, status: :internal_server_error
    end
  end
end

class AlertsController < ApplicationController
  before_action :authorize

  # GET /alerts?animal_id=2&start=YYYY-MM-DD&end=YYYY-MM-DD
  def index
    rel = Alert.includes(device_animal: :animal).order(detected_at: :desc)

    if params[:animal_id].present?
      rel = rel.for_animal(params[:animal_id])
    end

    if params[:start].present? && params[:end].present?
      start_at = Time.zone.parse(params[:start]).beginning_of_day
      end_at   = Time.zone.parse(params[:end]).end_of_day
      rel = rel.where(detected_at: start_at..end_at)
    end

    render json: rel.map { |a|
      {
        id: a.id,
        device_animal_id: a.device_animal_id,
        animal_id: a.animal_id,
        alert_type: a.alert_type,
        detected_at: a.detected_at,
        z_score: a.z_score
      }
    }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /alerts
  # Body JSON:
  # { device_animal_id, alert_type, detected_at, z_score } ==OU== { animal_id, alert_type, detected_at, z_score } -> resolve o vínculo ativo pelo detected_at
  def create
    payload = params.permit(:device_animal_id, :animal_id, :alert_type, :detected_at, :z_score)

    device_animal_id = payload[:device_animal_id]
    if device_animal_id.blank?

      animal_id = payload.require(:animal_id)
      detected_at = Time.zone.parse(payload.require(:detected_at))
      link = DeviceAnimal.covering(detected_at.to_date).where(animal_id: animal_id)
                         .order(start_date: :desc).first
      return render json: { error: "Sem vínculo ativo para o animal na data" }, status: :unprocessable_entity unless link
      device_animal_id = link.id
    end

    alert = Alert.create!(
      device_animal_id: device_animal_id,
      alert_type: payload.require(:alert_type),
      detected_at: Time.zone.parse(payload.require(:detected_at)),
      z_score: payload[:z_score]
    )

    render json: { id: alert.id }, status: :created
  rescue ActionController::ParameterMissing => e
    render json: { error: "Parâmetro obrigatório: #{e.param}" }, status: :bad_request
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # DELETE /alerts/:id
  def destroy
    alert = Alert.find(params[:id])
    alert.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Alert não encontrado" }, status: :not_found
  end
end

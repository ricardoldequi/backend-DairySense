module Api
    class AlertsController < ApplicationController
      before_action :authorize

      # GET /api/alerts?animal_id=2&start=YYYY-MM-DD&end=YYYY-MM-DD
      def index
        rel = Alert.includes(device_animal: :animal).order(detected_at: :desc)
        rel = rel.joins(:device_animal).where(device_animals: { animal_id: params[:animal_id] }) if params[:animal_id].present?

        if params[:start].present? && params[:end].present?
          start_at = Time.zone.parse(params[:start]).beginning_of_day
          end_at   = Time.zone.parse(params[:end]).end_of_day
          rel = rel.where(detected_at: start_at..end_at)
        end

        render json: rel.map { |a|
          {
            id: a.id,
            device_animal_id: a.device_animal_id,
            animal_id: a.device_animal.animal_id,
            alert_type: a.alert_type,
            detected_at: a.detected_at,
            z_score: a.z_score
          }
        }
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # GET /api/alerts/recent?since=ISO8601&last_id=123&animal_id=2&limit=100
      # Se last_id for informado, ignora since e retorna alerts com id > last_id.
      def recent
        limit = params[:limit].to_i
        limit = 100 if limit <= 0 || limit > 500

        rel = Alert.includes(device_animal: :animal)
        rel = rel.joins(:device_animal).where(device_animals: { animal_id: params[:animal_id] }) if params[:animal_id].present?

        if params[:last_id].present?
          rel = rel.where("alerts.id > ?", params[:last_id].to_i)
        else
          since = params[:since].present? ? Time.zone.parse(params[:since]) : 15.minutes.ago
          rel = rel.where("detected_at >= ?", since)
        end

        rel = rel.order(:detected_at).limit(limit)
        items = rel.map { |a|
          {
            id: a.id,
            device_animal_id: a.device_animal_id,
            animal_id: a.device_animal.animal_id,
            alert_type: a.alert_type,
            detected_at: a.detected_at,
            z_score: a.z_score,
            message: "Animal #{a.device_animal.animal_id} está com suspeita de cio em #{a.detected_at.iso8601}"
          }
        }

        last = items.last
        response.set_header("Last-Modified", last[:detected_at].httpdate) if last

        render json: {
          count: items.size,
          items: items,
          next_cursor: last ? { last_id: last[:id], since: last[:detected_at].iso8601 } : nil
        }
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
    end
    end
end

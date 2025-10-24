module Api
  class ActivityBaselinesController < ApplicationController
    before_action :authorize
    before_action :set_animal

    # GET /animals/:animal_id/activity_baselines?start=YYYY-MM-DD&end=YYYY-MM-DD
    def index
      rel = ActivityBaseline.where(animal_id: @animal.id).order(:hour_of_day)
      if params[:start].present? && params[:end].present?
        start_date = Date.parse(params[:start])
        end_date   = Date.parse(params[:end])
        rel = rel.where(period_start: start_date, period_end: end_date)
      end
      render json: rel.as_json(only: [ :animal_id, :hour_of_day, :baseline_enmo, :mad_enmo, :period_start, :period_end ])
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    # POST /animals/:animal_id/activity_baselines?start=YYYY-MM-DD&end=YYYY-MM-DD&window=10
    # se não passar window, usa 10 por padrao
    def create
      start_date = Date.parse(params.require(:start))
      end_date   = Date.parse(params.require(:end))
      window     = params[:window].to_i.positive? ? params[:window].to_i : 10

      if ActivityBaseline.where(
          animal_id: @animal.id,
          period_start: start_date,
          period_end: end_date
        ).exists?
        render json: {
          error: "Já existe baseline para este animal nesse período",
          animal_id: @animal.id, start: start_date, end: end_date
        }, status: :conflict
        return
      end

      # Verifica se existem leituras do animal no período da request
      start_at = start_date.in_time_zone.beginning_of_day
      end_at   = end_date.in_time_zone.end_of_day
      has_readings = Reading.where(animal_id: @animal.id, collected_at: start_at..end_at).exists?

      unless has_readings
        render json: {
          error: "Não há nenhuma informação sobre este animal nesse período",
          animal_id: @animal.id, start: start_date, end: end_date
        }, status: :not_found
        return
      end

      BaselineCalculator.new(
        animal: @animal,
        start_date: start_date,
        end_date: end_date,
        window_minutes: window
      ).call

      baselines = ActivityBaseline.where(animal_id: @animal.id, period_start: start_date, period_end: end_date)
                                  .order(:hour_of_day)

      render json: {
        status: "ok",
        animal_id: @animal.id,
        start: start_date,
        end: end_date,
        window_minutes: window,
        count: baselines.count
      }, status: :created
    rescue ActionController::ParameterMissing => e
      render json: { error: "Parâmetros obrigatórios: start e end" }, status: :bad_request
    rescue ArgumentError => e
      render json: { error: "Datas inválidas: #{e.message}" }, status: :unprocessable_entity
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end


    # DELETE /animals/:animal_id/activity_baselines?start=YYYY-MM-DD&end=YYYY-MM-DD
    def destroy
      start_date = Date.parse(params.require(:start))
      end_date   = Date.parse(params.require(:end))

      scope = ActivityBaseline.where(
        animal_id: @animal.id,
        period_start: start_date,
        period_end: end_date
      )
      deleted = scope.destroy_all

      render json: { deleted: deleted, animal_id: @animal.id, start: start_date, end: end_date }
    rescue ActionController::ParameterMissing
      render json: { error: "Parâmetros obrigatórios: start e end" }, status: :bad_request
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
    private

    def set_animal
      @animal = Animal.find(params[:animal_id])
    end
  end
end

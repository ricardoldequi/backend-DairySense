  module Authenticable
    extend ActiveSupport::Concern

    def authorize
      token = request.headers["Authorization"].to_s.sub(/^Bearer\s+/i, "")
      if token.blank?
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    included do
      before_action :authenticate_device!
    end

    private

    def authenticate_device!
      token = request.headers["Authorization"]
      return render json: { error: "Token não enviado" }, status: :unauthorized if token.blank?

      @current_device = Device.find_by(api_key: token)
      render json: { error: "Token inválido" }, status: :unauthorized unless @current_device
    end

    def current_device
      @current_device
    end
  end

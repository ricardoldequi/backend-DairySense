module Authenticable
  extend ActiveSupport::Concern

  # Opcional: mantém compat com controllers que chamam authorize
  def authorize
    token = bearer_token
    render json: { error: "Unauthorized" }, status: :unauthorized if token.blank?
  end

  included do
    before_action :authenticate_device!
  end

  def current_device
    @current_device
  end

  private

  def authenticate_device!
    key = extract_device_api_key
    return render json: { error: "Token não enviado" }, status: :unauthorized if key.blank?

    @current_device = Device.find_by(api_key: key)
    render json: { error: "Token inválido" }, status: :unauthorized unless @current_device
  end

  def extract_device_api_key
    # 1) Header dedicado
    request.headers["X-Device-Api-Key"].presence ||
    
      bearer_token.presence ||
     
      raw_authorization_key
  end

  def bearer_token
    auth = request.headers["Authorization"].to_s
    return nil unless auth =~ /^Bearer\s+/i
    auth.sub(/^Bearer\s+/i, "")
  end

  def raw_authorization_key
    auth = request.headers["Authorization"].to_s
    return nil if auth.blank? || auth =~ /^Bearer\s+/i
    auth
  end
end

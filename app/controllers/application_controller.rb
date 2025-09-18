class ApplicationController < ActionController::API
  private

  def authenticate_device!
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_device = Device.find_by(api_key: token)
    render json: { error: "Não autorizado" }, status: :unauthorized unless @current_device
  end

  def encode_token(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def decode_token(token = nil)
    auth_header = request.headers["Authorization"]
    if auth_header
      token = auth_header.split(" ").last
      begin
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256")
        Rails.logger.info "Decoded token: #{decoded}"
        decoded.first
      rescue JWT::DecodeError => e
        Rails.logger.error "Decode error: #{e.message}"
        nil
      end
    end
  end

  def authorized_user
    decoded_token = decode_token()
    if decoded_token
      user_id = decoded_token.with_indifferent_access[:user_id]
      @user = User.find_by(id: user_id)
    end
  end

  def authorize
    render json: { message: "Por favor, faça login" }, status: :unauthorized unless authorized_user
  end
end

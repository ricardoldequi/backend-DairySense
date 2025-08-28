class ApplicationController < ActionController::API
  before_action :authenticate_device!

  private

  def authenticate_device!
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_device = Device.find_by(api_key: token)
    render json: { error: "Não autorizado" }, status: :unauthorized unless @current_device
  end
end

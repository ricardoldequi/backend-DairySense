class DevicesController < ApplicationController
  before_action :set_device, only: [ :show, :update, :destroy ]
    before_action :authorize

  # GET /devices
  def index
    @devices = Device.all
    render json: @devices
  end

  # GET /devices/:id
  def show
    render json: @device
  end

  # POST /devices
  def create
    @device = Device.new(device_params)
    if @device.save
      render json: @device, status: :created
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /devices/:id
  def update
    if @device.update(device_params)
      render json: @device
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end

  # DELETE /devices/:id
  def destroy
    @device.destroy
    head :no_content
  end

  private
    def set_device
      @device = Device.find(params[:id])
    end

    def device_params
      params.require(:device).permit(:serial_number, :api_key)
    end
end

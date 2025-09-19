class DeviceAnimalsController < ApplicationController
  before_action :set_device_animal, only: %i[ show update destroy ]

  # GET /device_animals
  def index
    @device_animals = DeviceAnimal.all

    render json: @device_animals
  end

  # GET /device_animals/1
  def show
    render json: @device_animal
  end

  # POST /device_animals
  def create
    @device_animal = DeviceAnimal.new(device_animal_params)

    if @device_animal.save
      render json: @device_animal, status: :created, location: @device_animal
    else
      render json: @device_animal.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /device_animals/1
  def update
    if @device_animal.update(device_animal_params)
      render json: @device_animal
    else
      render json: @device_animal.errors, status: :unprocessable_entity
    end
  end

  # DELETE /device_animals/1
  def destroy
    @device_animal.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device_animal
      @device_animal = DeviceAnimal.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def device_animal_params
      params.expect(device_animal: [ :device_id, :animal_id, :start_date, :end_date ])
    end
end

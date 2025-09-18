class AnimalsController < ApplicationController
  before_action :set_animal, only: [ :show, :update, :destroy ]
  before_action :authorize

  # GET /animals
  def index
    @animals = Animal.all
    render json: @animals
  end

  # GET /animals/:id
  def show
    render json: @animal
  end

  # POST /animals
  def create
    @animal = Animal.new(animal_params)
    if @animal.save
      render json: @animal, status: :created
    else
      render json: @animal.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /animals/:id
  def update
    if @animal.update(animal_params)
      render json: @animal
    else
      render json: @animal.errors, status: :unprocessable_entity
    end
  end

  # DELETE /animals/:id
  def destroy
    @animal.destroy
    head :no_content
  end

  private
    def set_animal
      @animal = Animal.find(params[:id])
    end

    def animal_params
      params.require(:animal).permit(:user_id, :name, :breed_id, :age, :earring)
    end
end

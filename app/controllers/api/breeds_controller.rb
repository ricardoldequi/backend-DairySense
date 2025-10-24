module Api
  class BreedsController < ApplicationController
    before_action :authorize

    # GET /api/breeds
    def index
      breeds = Breed.order(:name).select(:id, :name, :created_at, :updated_at)
      render json: breeds
    end

    # GET /api/breeds/names
    def names
      names = Breed.order(:name).pluck(:name)
      render json: names
    end
  end
end

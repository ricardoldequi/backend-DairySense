module Api
  class UsersController < ApplicationController
    before_action :set_user, only: %i[ show update destroy ]
      before_action :authorize, except: [ :login ]

    # GET /users
    def index
      @users = User.all
      render json: @users
    end

    # GET /users/:id
    def show
      render json: @user
    end

    # POST /users
    def create
      if User.exists?(email: user_params[:email])
        render json: { errors: "E-mail não pode ser cadastrado" }, status: :unprocessable_entity
        return
      end

        if User.exists?(name: user_params[:name])
      render json: { errors: "Usuario não pode ser cadastrado" }, status: :unprocessable_entity
      return
        end

      @user = User.new(user_params)

      if @user.save
        token = encode_token({ user_id: @user.id })
        render json: { user: @user, token: token }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /users/1
    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # DELETE /users/1
    def destroy
      @user.destroy!
      head :no_content
    end

    # POST /login
    def login
      @user = User.find_by(email: params[:email])
      if @user && @user.authenticate(params[:password])
        token = encode_token({ user_id: @user.id })
        render json: { user: @user, token: token }, status: :ok
      else
        render json: { errors: "Usuário ou senha Inválidos" }, status: :unauthorized
      end
    end

    private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.permit(:name, :email, :password)
      end
  end
end

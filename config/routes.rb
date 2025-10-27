require "sidekiq/web"
require "sidekiq/cron/web"


Rails.application.routes.draw do
   Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USER"] && password == ENV["SIDEKIQ_PASSWORD"]
  end
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    root to: proc { [ 200, {}, [ "API DairySense" ] ] }


    resources :animals do
      resources :activity_baselines, only: [ :index, :create ] do
        collection { delete :destroy }
      end
    end

     resources :breeds, only: [ :index ] do
      collection { get :names }
    end

    resources :device_animals
    resources :devices
    resources :users do
      collection do
        post :login
      end
    end

    resources :readings, only: :create
    resources :alerts, only: [ :index, :create, :destroy ]
  end

   get "/health", to: proc { [ 200, {}, [ "ok" ] ] }
   get "/favicon.ico", to: proc { [ 204, {}, [] ] }
end

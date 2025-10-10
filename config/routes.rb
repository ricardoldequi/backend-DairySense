Rails.application.routes.draw do
  resources :animals do
    resources :activity_baselines, only: [ :index, :create ] do
      collection do
        delete :destroy
      end
    end
  end

  resources :device_animals
  resources :devices
  resources :users
  post "/login", to: "users#login"
    resources :readings, only: :create
      resources :alerts, only: [ :index, :create, :destroy ]
  get "/favicon.ico", to: proc { [ 204, {}, [] ] }
  root to: proc { [ 200, {}, [ "API DairySense" ] ] }
end

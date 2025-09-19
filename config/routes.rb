Rails.application.routes.draw do
  resources :device_animals
  resources :devices
  resources :animals
  resources :users
  post "/login", to: "users#login"
  resources :readings, only: [ :create, :index ]
  root to: proc { [ 200, {}, [ "API DairySense" ] ] }
  get "/favicon.ico", to: proc { [ 204, {}, [] ] }
end

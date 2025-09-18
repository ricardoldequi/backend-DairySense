Rails.application.routes.draw do
  root to: proc { [ 200, {}, [ "API DairySense" ] ] }
  get "/favicon.ico", to: proc { [ 204, {}, [] ] }
  resources :devices
  resources :animals
  resources :users
  post "/login", to: "users#login"
  resources :readings, only: [ :create, :index ]
end

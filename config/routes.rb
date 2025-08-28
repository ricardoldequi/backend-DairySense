Rails.application.routes.draw do
  resources :readings, only: [ :create, :index ]
end

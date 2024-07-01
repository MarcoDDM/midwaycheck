Rails.application.routes.draw do
  root 'locations#new'
  resources :locations, only: [:new, :create]
end

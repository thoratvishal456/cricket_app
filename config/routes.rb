Rails.application.routes.draw do
  resources :matches,  only: [:new, :create, :index]
  root to: "home#index"
  get 'home/index'
end

Rails.application.routes.draw do
  resources :matches,  only: [:new, :edit, :create, :index]
  patch "matches/update_score/:id" => "matches#update_score", as: :match_update_score
  get "matches/show_result/" => "matches#show_result", as: :match_show_result

  root to: "home#index"
  get 'home/index'
end

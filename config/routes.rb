Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :offerings, only: :show

  namespace :api, defaults: { format: :json } do
    resources :offerings, only: :show do
      resources :investments, only: :create
    end
  end
end

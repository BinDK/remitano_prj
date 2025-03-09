require 'sidekiq/web'

Rails.application.routes.draw do
  # disable Sidekiq Web UI in production
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  post 'users/sign_in_or_sign_up', to: 'users#sign_in_or_sign_up'
  devise_for :users

  namespace :api do
    namespace :v1 do
      resources :videos, only: [:index, :create]
      resources :users, only: [] do
        collection do
          get :current
          post :sign_in_or_sign_up
          delete :logout
        end
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :videos, only: [:index, :new, :create]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"
end

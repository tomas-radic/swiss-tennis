Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'players#index'

  resources :users, only: [:edit, :update]
  resources :sessions, only: [:new, :create, :destroy]
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  # resources :seasons
  resources :categories
  resources :players
  resources :rounds
  resources :matches

  # Static pages
  get '/pages/about', to: 'pages#about'
end

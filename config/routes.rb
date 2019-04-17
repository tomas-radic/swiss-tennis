Rails.application.routes.draw do
  resources :matches
  resources :seasons
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'players#index'

  resources :users, only: [:edit, :update]
  resources :sessions, only: [:new, :create, :destroy]
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resources :categories
  resources :players
  resources :rounds

  get '/pages/about', to: 'pages#about'
end

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'matches#index'
  # root to: "pages#season2024"

  resources :users, only: [:edit, :update]
  resources :sessions, only: [:new, :create, :destroy]
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resources :categories
  resources :places

  resources :enrollments, only: [:index, :new, :create] do
    get :cancel, on: :member
  end
  resources :players, only: [:show, :edit, :update]
  resources :rounds, except: [:destroy] do
    post 'toss_matches', on: :member
    get 'publish_all_matches', on: :member
  end
  resources :matches do
    post 'finish', on: :member
    get 'swap_players', on: :member
  end
  resources :rankings, only: [:index]
  resources :http_requests, only: [:index]


  # Static pages
  get '/pages/about', to: 'pages#about'
  get '/pages/season-jumpers', to: 'pages#season_jumpers'
  get '/pages/rules', to: 'pages#rules'
  get '/pages/season2024', to: 'pages#season2024'
  get '/pages/reservations', to: 'pages#reservations'

  resources :articles do
    get :pin, on: :member
    get :load_content, on: :member
  end

  resources :payments, only: [:index, :new, :create]
  resources :seasons, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :history_seasons, only: [:index, :show]
end

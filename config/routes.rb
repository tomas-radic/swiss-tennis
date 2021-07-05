Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'matches#index'

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
  resources :matches do
    post 'finish', on: :member
    get 'swap_players', on: :member
  end
  resources :rankings, only: [:index]


  # Static pages
  get '/pages/about', to: 'pages#about'
  get '/pages/season-jumpers', to: 'pages#season_jumpers'
  get '/pages/game_rules', to: 'pages#game_rules'
  # get '/pages/season2020', to: 'pages#season2020'
  get '/pages/season2021', to: 'pages#season2021'

  resources :articles do
    get :pin, on: :member
    get :load_content, on: :member
  end

  resources :payments, only: [:index, :new, :create]
  resources :history_seasons, only: [:index, :show]

  # Manager namespace - managing the competition, requires logged in user
  namespace :manager do
    # Seasons
    resources :seasons, only: [:index, :new, :create, :edit, :update, :destroy]

    # Rounds
    resources :rounds, except: [:destroy] do
      post 'toss_matches', on: :member
      get 'publish_all_matches', on: :member
    end
  end
end

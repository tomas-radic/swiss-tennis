Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'matches#index'
  # root to: 'enrollments#index'

  resources :users, only: [:edit, :update]
  resources :sessions, only: [:new, :create, :destroy]
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resources :categories
  # resources :seasons, except: [:index, :show, :new, :create, :edit, :update, :destroy] do
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
  # end

  # Static pages
  get '/pages/about', to: 'pages#about'
  # get '/pages/season2020', to: 'pages#season2020'

  resources :articles do
    get :pin, on: :member
  end

  resources :payments, only: [:index]
end

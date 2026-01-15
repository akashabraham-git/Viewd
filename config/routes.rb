Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :movies do
        member do
          post :toggle_watched,   to: 'library_entries#toggle_watched'   
          post :toggle_watchlist, to: 'library_entries#toggle_watchlist'
          post 'like', to: 'likes#toggle_movie_like'
          post 'rating', to: 'ratings#toggle'
        end
        
        resources :reviews, only: [:index, :show, :create]
      end

      resources :reviews, only: [:show, :update, :destroy]

      post 'reviews/:id/like', to: 'likes#toggle_review_like', as: :review_like

      resources :casts, only: [:index, :show, :create, :update, :destroy]

      resources :genres, only: [:index, :show, :create, :update, :destroy]

      resources :users, only: [:show, :update, :destroy] do
        resources :connections, only: [:index]
      end
      
      resources :connections, only: [:create, :destroy]
      
      resources :members do
        member do
          get :watchlist
          get :likes
          get :library
          get :reviews
        end
      end

      resources :moderators

      resources :memberships, only: [:index, :update, :show]
      
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  devise_for :users

  root "movies#index"
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest




  resources :movies do
    member do
      post :toggle_watched,   to: 'library_entries#toggle_watched'
      post :toggle_watchlist, to: 'library_entries#toggle_watchlist'
      post :toggle_movie_like, to: 'likes#toggle_movie_like'
      post :toggle_rating,     to: 'ratings#toggle'
    end

    resources :reviews do
      member do
        post :toggle_like, to: 'likes#toggle_review_like'
      end
    end

    resources :library_entries, only: [:create, :update, :destroy]
  end

  resources :users, except: [:index]

  resources :members, only: [] do
    member do
      get :library
      get :watchlist
      get :likes
      get :reviews
    end
  end

  resources :casts
  resources :genres
  resources :memberships, only: [:index, :update]
  resources :connections,   only: [:index, :create, :destroy]


end




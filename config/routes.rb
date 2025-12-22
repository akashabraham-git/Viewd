Rails.application.routes.draw do
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest


  resources :movies, only: [:index, :show] do
    post 'toggle_watched', to: 'library_entries#toggle_watched'
    post 'toggle_watchlist', to: 'library_entries#toggle_watchlist'
    post 'toggle_movie_like', to: 'likes#toggle_movie_like'
    post 'toggle_rating', to: 'ratings#toggle'
    resources :reviews, only: [:create, :edit, :update, :destroy, :index] do
      post 'toggle_like', to: 'likes#toggle_review_like', on: :member, as: :toggle_like
    end
  end


  get 'users/:id/library', to: 'users#library', as: :library_user
  get 'users/:id/watchlist', to: 'users#watchlist', as: :watchlist_user
  get 'users/:id/likes', to: 'users#likes', as: :user_likes
  get 'users/:id/reviews', to: 'users#reviews', as: :user_reviews

  resources :users, only: [:show, :edit, :update, :destroy]
  resources :favorites, only: [:create, :destroy]
  resources :connections, only: [:index, :create, :destroy]
  resources :cast, only: [:show]
  resources :reviews, only: [:show, :create, :edit, :destroy]
  resources :memberships, only: [:index, :update]
    
    root "movies#index"
end

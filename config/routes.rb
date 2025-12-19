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
    post 'ratings', to: 'ratings#create_or_update'
    post 'toggle_watched', to: 'library_entries#toggle_watched'
    post 'toggle_watchlist', to: 'library_entries#toggle_watchlist'
    post 'toggle_movie_like', to: 'likes#toggle_movie_like'
    resources :reviews, only: [:create]
  end

  resources :users, only: [:show]
  resources :follows, only: [:create]
  
  root "movies#index"
end

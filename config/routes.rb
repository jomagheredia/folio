# frozen_string_literal: true

Rails.application.routes.draw do
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get  "signup", to: "registrations#new",    as: :signup
  post "signup", to: "registrations#create"

  resources :passwords, param: :token, only: %i[ new create edit update ]

  get "dashboard", to: "dashboard#show", as: :dashboard
  get "settings",  to: "settings#show",  as: :settings

  resources :bookmarks do
    collection do
      post :preview, to: "bookmarks/previews#create"
    end
    resource :ai, only: [], module: :bookmarks, controller: :ai do
      post :description
      post :tags
    end
  end
  resources :tags, only: %i[ index show update destroy ]
  resources :collections do
    member do
      post :add_bookmark
      delete :remove_bookmark
    end
    resource :ai, only: [], module: :collections, controller: :ai do
      post :summary
    end
  end
  resources :shares, only: %i[ new create ]

  namespace :admin do
    root to: redirect("/admin/users")
    get "design-system", to: "design_system#show", as: :design_system
    resources :users, only: %i[ index show ]
  end

  get   "profile",          to: "profiles#details",          as: :profile
  get   "profile/password", to: "profiles#password",         as: :profile_password
  patch "profile/email",    to: "profiles#update_email"
  patch "profile/password", to: "profiles#update_password"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end

Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks",
    :registrations => "registrations"
  }

  root to: "home#index"
  get "/feed" => "home#feed"
  get "/friends" => "users#friends"
  post "/search/users" => "search#users"
  get "/search/user_slyps" => "search#user_slyps"

  resources :beta_request, only: [:create]
  resources :users, only: [:index]
  resources :user_slyps, only: [:create, :index, :show, :update]
  resources :reslyps, only: [:create, :index, :destroy]
  resources :slyps, only: [:create]
  resource :user

  # Make sure this is last
  get "*unmatched_route", :to => redirect("/")
end

# frozen_string_literal: true

Rails.application.routes.draw do
  get 'user_search/index'
  resources :users
  root 'application#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

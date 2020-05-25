# frozen_string_literal: true

Rails.application.routes.draw do
  get 'user_search', to: 'user_search#index'
  get 'health_check', to: 'health_check#index'
  resources :users
  resources :repositories
  resources :jira
  root 'application#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

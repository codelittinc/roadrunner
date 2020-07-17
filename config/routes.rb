# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'user_search', to: 'user_search#index'
  get 'health_check', to: 'health_check#index'
  get 'projects_status', to: 'projects_status#index'
  get 'incidents', to: 'incidents#index'
  post 'flows', to: 'flow#create'
  get 'slack_messages/:github_id/:repository_name', to: 'slack#index'

  resources :users
  resources :repositories
  resources :servers

  root 'application#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

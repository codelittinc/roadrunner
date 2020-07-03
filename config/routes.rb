# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'user_search', to: 'user_search#index'
  get 'health_check', to: 'health_check#index'
  get 'projects_status', to: 'projects_status#index'
  get 'incidents', to: 'incidents#index'
  post 'flows', to: 'flow#create'

  resources :users
  resources :repositories

  root 'application#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

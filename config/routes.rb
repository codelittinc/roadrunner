# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  resources :channels, only: [:index]
  resources :projects
  resources :pull_requests, only: %i[index show]
  resources :code_comments, only: %i[index]
  resources :organizations
  resources :repositories do
    resources :applications
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Sidekiq::Web => '/sidekiq'

  post 'flows', to: 'flow#create'
  get 'api/oauth/github', to: 'api/oauth/github#create'

  root 'application#index'
end

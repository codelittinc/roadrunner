# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
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

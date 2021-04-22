# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'projects_status', to: 'projects_status#index'
  get 'incidents', to: 'incidents#index'
  post 'flows', to: 'flow#create'

  resources :open_pull_requests, only: :index, defaults: { format: :json }
  resources :server_incidents_report, only: :show, defaults: { format: :json }
  resources :projects, only: %i[index show create update destroy], defaults: { format: :json }
  resources :applications, only: %i[index show create update destroy], defaults: { format: :json } do
    resources :servers, only: %i[index show create update destroy], defaults: { format: :json }
    resources :releases, only: :show, defaults: { format: :json }
  end
  resources :repositories, only: %i[index show create update destroy], defaults: { format: :json }

  root 'application#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

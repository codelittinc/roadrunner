# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationsController, type: :controller do
  render_views

  let(:repository) { FactoryBot.create(:repository) }

  describe '#index' do
    it 'displays all applications' do
      FactoryBot.create(:application)
      FactoryBot.create(:application)
      get :index, format: :json

      applications_count = JSON.parse(response.body).length
      expect(applications_count).to be(2)
    end

    it 'displays the correct applications data' do
      FactoryBot.create(:application)
      FactoryBot.create(:application, environment: 'dev')
      get :index, format: :json

      environment = JSON.parse(response.body)[1]['environment']
      expect(environment).to eq('dev')
    end
  end

  describe '#show' do
    it 'returns the application data as JSON' do
      application = FactoryBot.create(:application, environment: 'dev')
      get :show, format: :json, params: { id: application }

      environment = JSON.parse(response.body)['environment']
      expect(environment).to eq('dev')
    end
  end

  describe '#create' do
    it 'creates a application' do
      json = {
        application: {
          repository_id: repository,
          environment: 'dev'
        }
      }
      expect { post :create, params: json }.to change { Application.count }.by(1)
    end

    it 'returns the application data as JSON' do
      json = {
        application: {
          repository_id: repository,
          environment: 'dev'
        }
      }
      post :create, params: json

      environment = JSON.parse(response.body)['environment']
      expect(environment).to eq('dev')
    end

    it 'returns an error message when fails to create' do
      json = {
        application: {
          repository_id: repository
        }
      }
      post :create, params: json

      error = JSON.parse(response.body)['error']
      expect(error).to eq('environment' => ["can't be blank", 'is not included in the list'])
    end
  end

  describe '#update' do
    it 'updates a application and returns its data as JSON' do
      application = FactoryBot.create(:application, environment: 'dev')
      patch :update, params: { id: application, application: { environment: 'qa' } }

      environment = JSON.parse(response.body)['environment']
      expect(environment).to eq('qa')
    end

    it 'returns an error message when fails to update' do
      application = FactoryBot.create(:application)
      patch :update, params: { id: application, application: { environment: '' } }

      error = JSON.parse(response.body)['error']
      expect(error).to eq('environment' => ["can't be blank", 'is not included in the list'])
    end
  end

  describe '#destroy' do
    it 'deletes the application' do
      application = FactoryBot.create(:application)

      expect { delete :destroy, params: { id: application } }
        .to change { Application.count }.from(1).to(0)
    end
  end
end

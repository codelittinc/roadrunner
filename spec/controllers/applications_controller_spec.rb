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
      FactoryBot.create(:application, version: 'Second')
      get :index, format: :json

      version = JSON.parse(response.body)[1]['version']
      expect(version).to eq('Second')
    end
  end

  describe '#show' do
    it 'returns the application data as JSON' do
      application = FactoryBot.create(:application, version: 'version')
      get :show, format: :json, params: { id: application }

      version = JSON.parse(response.body)['version']
      expect(version).to eq('version')
    end
  end

  describe '#create' do
    it 'creates a application' do
      json = {
        application: {
          repository_id: repository,
          environment: 'dev',
          version: 'ver',
          external_identifier: 'ident'
        }
      }
      expect { post :create, params: json }.to change { Application.count }.by(1)
    end

    it 'returns the application data as JSON' do
      json = {
        application: {
          repository_id: repository,
          environment: 'dev',
          version: 'ver',
          external_identifier: 'ident'
        }
      }
      post :create, params: json

      external_identifier = JSON.parse(response.body)['external_identifier']
      expect(external_identifier).to eq('ident')
    end

    it 'returns an error message when fails to create' do
      json = {
        application: {
          repository_id: repository,
          environment: 'dev',
          version: 'ver'
        }
      }
      post :create, params: json

      error = JSON.parse(response.body)['error']
      expect(error).to eq('external_identifier' => ["can't be blank"])
    end
  end

  describe '#update' do
    it 'updates a application and returns its data as JSON' do
      application = FactoryBot.create(:application, version: 'Before update')
      patch :update, params: { id: application, application: { version: 'After update' } }

      version = JSON.parse(response.body)['version']
      expect(version).to eq('After update')
    end

    it 'returns an error message when fails to update' do
      application = FactoryBot.create(:application)
      patch :update, params: { id: application, application: { version: '' } }

      error = JSON.parse(response.body)['error']
      expect(error).to eq('version' => ["can't be blank"])
    end
  end
end

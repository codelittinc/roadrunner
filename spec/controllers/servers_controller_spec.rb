# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServersController, type: :controller do
  render_views

  let(:application) { FactoryBot.create(:application) }

  describe '#index' do
    it 'displays all active servers' do
      FactoryBot.create(:server)
      FactoryBot.create(:server)
      get :index, format: :json, params: { application_id: application }

      servers_count = JSON.parse(response.body).length
      expect(servers_count).to be(2)
    end

    it 'displays the correct servers data' do
      FactoryBot.create(:server)
      FactoryBot.create(:server, link: 'link')
      get :index, format: :json, params: { application_id: application }

      link = JSON.parse(response.body)[1]['link']
      expect(link).to eq('link')
    end
  end

  describe '#show' do
    it 'returns the server data as JSON' do
      server = FactoryBot.create(:server, link: 'link')
      get :show, format: :json, params: { id: server, application_id: application }

      link = JSON.parse(response.body)['link']
      expect(link).to eq('link')
    end
  end

  describe '#create' do
    it 'creates a server' do
      json = {
        application_id: application, server: {
          application_id: application,
          link: 'link'
        }
      }
      expect { post :create, params: json }.to change { Server.count }.by(1)
    end

    it 'returns the server data as JSON' do
      json = {
        application_id: application, server: {
          application_id: application,
          link: 'link'
        }
      }
      post :create, params: json

      link = JSON.parse(response.body)['link']
      expect(link).to eq('link')
    end

    it 'returns an error message when fails to create' do
      json = {
        application_id: application, server: {
          application_id: application
        }
      }
      post :create, params: json

      error = JSON.parse(response.body)['error']
      expect(error).to eq('link' => ["can't be blank"])
    end
  end

  describe '#update' do
    it 'updates a server and returns its data as JSON' do
      server = FactoryBot.create(:server, link: 'Before update')
      patch :update, params: {
        application_id: application,
        id: server,
        server: { link: 'After update' }
      }

      link = JSON.parse(response.body)['link']
      expect(link).to eq('After update')
    end

    it 'returns an error message when fails to update' do
      server = FactoryBot.create(:server, link: 'Before update')
      patch :update, params: {
        application_id: application,
        id: server,
        server: { link: '' }
      }

      error = JSON.parse(response.body)['error']
      expect(error).to eq('link' => ["can't be blank"])
    end
  end

  describe '#destroy' do
    it 'deletes the server' do
      server = FactoryBot.create(:server)

      expect { delete :destroy, params: { application_id: application, id: server } }
        .to change { Server.count }.from(1).to(0)
    end
  end
end

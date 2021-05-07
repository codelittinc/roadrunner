# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepositoriesController, type: :controller do
  render_views

  let(:project) { FactoryBot.create(:project) }

  describe '#index' do
    it 'displays all repositories' do
      FactoryBot.create(:repository)
      FactoryBot.create(:repository)
      get :index, format: :json

      repositories_count = JSON.parse(response.body).length
      expect(repositories_count).to be(2)
    end

    it 'displays the correct repositories data' do
      FactoryBot.create(:repository)
      FactoryBot.create(:repository, friendly_name: 'Second repo')
      get :index, format: :json

      repository_name = JSON.parse(response.body)[1]['friendly_name']
      expect(repository_name).to eq('Second repo')
    end
  end

  describe '#show' do
    it 'returns the repository data as JSON' do
      repository = FactoryBot.create(:repository, friendly_name: 'repository')
      get :show, format: :json, params: { id: repository }

      friendly_name = JSON.parse(response.body)['friendly_name']
      expect(friendly_name).to eq('repository')
    end
  end

  describe '#create' do
    it 'creates a repository' do
      json = {
        repository: {
          project_id: project.id,
          name: 'testing',
          friendly_name: 'test repo',
          source_control_type: 'github'
        }
      }
      allow_any_instance_of(Clients::Github::Repository).to receive(:get_repository)
      allow_any_instance_of(Clients::Github::Hook).to receive(:create)

      expect { post :create, params: json }.to change { Repository.count }.by(1)
    end

    it 'creates a slack repository info' do
      json = {
        repository: {
          project_id: project.id,
          name: 'testing',
          friendly_name: 'test repo',
          source_control_type: 'github',
          slack_repository_info_attributes: { deploy_channel: 'test' }
        }
      }
      allow_any_instance_of(Clients::Github::Repository).to receive(:get_repository)
      allow_any_instance_of(Clients::Github::Hook).to receive(:create)

      expect { post :create, params: json }.to change { SlackRepositoryInfo.count }.by(1)
    end

    it 'slack repository info has the correct attributes' do
      json = {
        repository: {
          project_id: project.id,
          name: 'testing',
          friendly_name: 'test repo',
          source_control_type: 'github',
          slack_repository_info_attributes: { deploy_channel: 'test' }
        }
      }
      allow_any_instance_of(Clients::Github::Repository).to receive(:get_repository)
      allow_any_instance_of(Clients::Github::Hook).to receive(:create)

      post :create, params: json

      expect(SlackRepositoryInfo.last).to have_attributes(deploy_channel: 'test')
    end

    it 'returns the repository data as JSON' do
      json = {
        repository: {
          project_id: project.id,
          name: 'testing',
          friendly_name: 'test repo',
          source_control_type: 'github'
        }
      }

      allow_any_instance_of(Clients::Github::Repository).to receive(:get_repository)
      allow_any_instance_of(Clients::Github::Hook).to receive(:create)

      post :create, params: json

      name = JSON.parse(response.body)['name']
      expect(name).to eq('testing')
    end

    it 'returns an error message when fails to create' do
      json = { repository: { friendly_name: 'test repo', source_control_type: 'github' } }

      allow_any_instance_of(Clients::Github::Repository).to receive(:get_repository)
      allow_any_instance_of(Clients::Github::Hook).to receive(:create)

      post :create, params: json

      error = JSON.parse(response.body)['error']
      expect(error).to eq('project' => ['must exist'])
    end
  end

  describe '#update' do
    it 'updates a repository and returns its data as JSON' do
      repository = FactoryBot.create(:repository)
      patch :update, params: { id: repository, repository: { friendly_name: 'After update' } }

      friendly_name = JSON.parse(response.body)['friendly_name']
      expect(friendly_name).to eq('After update')
    end

    it 'returns an error message when fails to update' do
      repository = FactoryBot.create(:repository)
      patch :update, params: { id: repository, repository: { friendly_name: '' } }

      error = JSON.parse(response.body)['error']
      expect(error).to eq('friendly_name' => ["can't be blank"])
    end
  end

  describe '#destroy' do
    it 'deletes the repository' do
      repository = FactoryBot.create(:repository)

      expect { delete :destroy, params: { id: repository } }
        .to change { Repository.count }.from(1).to(0)
    end
  end
end

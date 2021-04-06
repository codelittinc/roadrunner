# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepositoriesController, type: :controller do
  let(:project) { FactoryBot.create(:project) }

  describe '#index' do
    it 'displays all repositories' do
      FactoryBot.create(:repository)
      FactoryBot.create(:repository)
      get :index

      repositories_count = JSON.parse(response.body).length
      expect(repositories_count).to be(2)
    end

    it 'displays the correct repositories data' do
      FactoryBot.create(:repository)
      FactoryBot.create(:repository, name: 'Second repository')
      get :index

      repository_name = JSON.parse(response.body)[1]['name']
      expect(repository_name).to eq('Second repository')
    end
  end

  describe '#create' do
    it 'creates a repository' do
      json = {
        repository: {
          project_id: project.id,
          name: 'testing'
        }
      }
      expect { post :create, params: json }.to change { Repository.count }.by(1)
    end

    it 'creates a slack repository info' do
      json = {
        repository: {
          project_id: project.id,
          name: 'testing',
          slack_repository_info_attributes: { deploy_channel: 'test' }
        }
      }
      expect { post :create, params: json }.to change { SlackRepositoryInfo.count }.by(1)
    end

    it 'slack repository info has the correct attributes' do
      json = {
        repository: {
          project_id: project.id,
          name: 'testing',
          slack_repository_info_attributes: { deploy_channel: 'test' }
        }
      }
      post :create, params: json

      expect(SlackRepositoryInfo.last).to have_attributes(deploy_channel: 'test')
    end

    it 'returns the repository data as JSON' do
      json = {
        repository: {
          project_id: project.id,
          name: 'testing'
        }
      }
      post :create, params: json

      name = JSON.parse(response.body)['name']
      expect(name).to eq('testing')
    end

    it 'returns an error message when fails to create' do
      json = { repository: { name: 'testing' } }
      post :create, params: json

      error = JSON.parse(response.body)['error']
      expect(error).to eq('project' => ['must exist'])
    end
  end

  describe '#update' do
    it 'updates a repository and returns its data as JSON' do
      repository = FactoryBot.create(:repository, name: 'Before update')
      patch :update, params: { id: repository, repository: { name: 'After update' } }

      name = JSON.parse(response.body)['name']
      expect(name).to eq('After update')
    end

    it 'returns an error message when fails to update' do
      repository = FactoryBot.create(:repository)
      patch :update, params: { id: repository, repository: { project_id: '' } }

      error = JSON.parse(response.body)['error']
      expect(error).to eq('project' => ['must exist'])
    end
  end
end

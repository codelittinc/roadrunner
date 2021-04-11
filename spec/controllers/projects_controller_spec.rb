# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  render_views

  describe '#index' do
    it 'displays all projects' do
      FactoryBot.create(:project)
      FactoryBot.create(:project)
      get :index, format: :json

      projects_count = JSON.parse(response.body).length
      expect(projects_count).to be(2)
    end

    it 'displays the correct projects data' do
      FactoryBot.create(:project)
      FactoryBot.create(:project, name: 'Second')
      get :index, format: :json

      name = JSON.parse(response.body)[1]['name']
      expect(name).to eq('Second')
    end
  end

  describe '#show' do
    it 'returns the project data as JSON' do
      project = FactoryBot.create(:project, name: 'project')
      get :show, format: :json, params: { id: project }

      name = JSON.parse(response.body)['name']
      expect(name).to eq('project')
    end
  end

  describe '#create' do
    it 'creates a project' do
      json = { project: { name: 'project' } }
      expect { post :create, params: json }.to change { Project.count }.by(1)
    end

    it 'returns the project data as JSON' do
      json = { project: { name: 'project' } }
      post :create, params: json

      name = JSON.parse(response.body)['name']
      expect(name).to eq('project')
    end
  end

  describe '#update' do
    it 'updates a project and returns its data as JSON' do
      project = FactoryBot.create(:project, name: 'Before update')
      patch :update, params: { id: project.id, project: { name: 'After update' } }

      name = JSON.parse(response.body)['name']
      expect(name).to eq('After update')
    end
  end

  describe '#destroy' do
    it 'deletes the project' do
      project = FactoryBot.create(:project)

      expect { delete :destroy, params: { id: project.id } }
        .to change { Project.count }.from(1).to(0)
    end
  end
end

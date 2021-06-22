# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  render_views

  let(:customer) { FactoryBot.create(:customer) }

  describe '#index' do
    it 'displays all projects' do
      FactoryBot.create(:project)
      FactoryBot.create(:project)
      get :index, format: :json

      projects_count = JSON.parse(response.body).length
      expect(projects_count).to be(2)
    end

    it 'displays the correct projects data' do
      project = FactoryBot.create(:project)
      get :index, format: :json

      id = JSON.parse(response.body)[0]['id']
      expect(id).to eq(project.id)
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
      json = { project: { name: 'project', customer_id: customer } }
      expect { post :create, params: json }.to change { Project.count }.by(1)
    end

    it 'returns the project data as JSON' do
      json = { project: { name: 'project', customer_id: customer } }
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateRepositoryService, type: :service do
  let(:project) { FactoryBot.create(:project) }

  describe '#create' do
    it 'creates a new repo' do
      create_repo_service = described_class.new({
                                                  name: 'teste',
                                                  friendly_name: 'test repo',
                                                  project_id: project.id,
                                                  owner: 'codelittinc',
                                                  deploy_type: 'tag',
                                                  supports_deploy: true,
                                                  jira_project: nil,
                                                  source_control_type: 'github'
                                                })

      expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository)

      expect { create_repo_service.create }.to change { Repository.count }.by(1)
    end

    it 'creates a hook for the new repo' do
      create_repo_service = described_class.new({
                                                  name: 'gh-hooks-repo-test',
                                                  friendly_name: 'test repo',
                                                  project_id: project.id,
                                                  owner: 'codelittinc',
                                                  deploy_type: 'tag',
                                                  supports_deploy: true,
                                                  jira_project: nil,
                                                  source_control_type: 'github'
                                                })

      allow_any_instance_of(Clients::Github::Repository).to receive(:get_repository)
      allow_any_instance_of(Clients::Github::Hook).to receive(:create)

      expect { create_repo_service.create }.to change { Repository.count }.by(1)
    end

    it 'creates a slack repository info' do
      create_repo_service = described_class.new({
                                                  name: 'teste',
                                                  friendly_name: 'test repo',
                                                  project_id: project.id,
                                                  owner: 'codelittinc',
                                                  deploy_type: 'tag',
                                                  supports_deploy: true,
                                                  jira_project: nil,
                                                  slack_repository_info_attributes: {
                                                    deploy_channel: 'test'
                                                  },
                                                  source_control_type: 'github'
                                                })

      expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository)

      expect { create_repo_service.create }.to change { SlackRepositoryInfo.count }.by(1)
    end
  end
end

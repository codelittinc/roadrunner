# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateRepositoryService, type: :service do
  describe '#create' do
    it 'creates a new repo' do
      project = FactoryBot.create(:project)
      create_repo_service = described_class.new(project, {
                                                  name: 'teste',
                                                  owner: 'codelittinc',
                                                  deploy_type: 'tag',
                                                  supports_deploy: true,
                                                  alias: '',
                                                  jira_project: nil
                                                })

      expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository)

      expect { create_repo_service.create }.to change { Repository.count }.by(1)
    end

    it 'creates a hook for the new repo' do
      project = FactoryBot.create(:project)
      create_repo_service = described_class.new(project, {
                                                  name: 'gh-hooks-repo-test',
                                                  owner: 'codelittinc',
                                                  deploy_type: 'tag',
                                                  supports_deploy: true,
                                                  alias: '',
                                                  jira_project: nil
                                                })

      allow_any_instance_of(Clients::Github::Repository).to receive(:get_repository)
      allow_any_instance_of(Clients::Github::Hook).to receive(:create)

      expect { create_repo_service.create }.to change { Repository.count }.by(1)
    end
  end
end

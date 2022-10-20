# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateRepositoryService, type: :service do
  let(:project) { FactoryBot.create(:project) }

  describe '#call' do
    context 'with valid params' do
      let(:valid_params) do
        {
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
        }
      end

      it 'creates a new repo' do
        expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository).and_return({})
        allow_any_instance_of(Clients::Github::Hook).to receive(:create)

        expect { described_class.call(valid_params) }.to change { Repository.count }.by(1)
      end

      it 'returns the repository instance' do
        expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository).and_return({})
        allow_any_instance_of(Clients::Github::Hook).to receive(:create)

        expect(described_class.call(valid_params)).to be_an_instance_of(Repository)
      end

      it 'creates a hook for the new repo' do
        expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository).and_return({})
        expect_any_instance_of(Clients::Github::Hook).to receive(:create)

        described_class.call(valid_params)
      end

      it 'creates a slack repository info' do
        expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository).and_return({})
        allow_any_instance_of(Clients::Github::Hook).to receive(:create)

        expect { described_class.call(valid_params) }.to change { SlackRepositoryInfo.count }.by(1)
      end
    end
    context 'with valid params' do
      let(:invalid_params) do
        {
          name: 'teste'
        }
      end

      it 'returns the repository instance with the errors' do
        repository = described_class.call(invalid_params)

        expect(repository).to be_invalid
      end

      it 'does not create a repository if there is an error with the source control' do
        params_with_wrong_name_on_source_control = {
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
        }

        expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository).and_raise(ActiveRecord::StaleObjectError)

        expect { described_class.call(params_with_wrong_name_on_source_control) }.to change {
                                                                                       SlackRepositoryInfo.count
                                                                                     }.by(0)
      end

      it 'returns a repository with errors if there is an error with the source control' do
        params_with_wrong_name_on_source_control = {
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
        }

        expect_any_instance_of(Clients::Github::Repository).to receive(:get_repository).and_raise(ActiveRecord::StaleObjectError)

        expect(described_class.call(params_with_wrong_name_on_source_control)).to be_an_instance_of(Repository)
      end
    end
  end
end

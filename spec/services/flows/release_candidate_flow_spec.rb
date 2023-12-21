# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

# We need to use the Flows::ReleaseFlow since it prepares the execution of the ReleaseCandidateFlow
RSpec.describe Flows::ReleaseFlow, type: :service do
  around do |example|
    ClimateControl.modify NOTIFICATIONS_API_URL: 'https://api.notifications.codelitt.dev' do
      example.run
    end
  end

  let(:valid_json) do
    {
      text: 'update qa',
      channel_name: 'feed-test-automations'
    }
  end

  context 'when the repository type is Github' do
    describe '#run' do
      context 'When the repository belongs to Github' do
        let(:github_repository_with_applications) do
          repository = FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-repository-test',
                                                      source_control_type: 'github')
          repository.applications << FactoryBot.create(:application, repository:, environment: 'qa')
          repository
        end
        context 'when it is the first pre-release' do
          it 'creates the first pre-release' do
            VCR.use_cassette('flows#pre-release#first') do
              repository = github_repository_with_applications
              repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

              pull_request = FactoryBot.create(:pull_request, repository:)

              FactoryBot.create(:commit, {
                                  message: 'commit number one',
                                  pull_request:
                                })

              FactoryBot.create(:commit, {
                                  message: 'commit number two',
                                  pull_request:
                                })

              flow = described_class.new(valid_json)

              expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
                github_repository_with_applications,
                'rc.1.v1.0.0',
                'master',
                "Available in the release of *roadrunner-repository-test*:\n - commit number one \n - commit number two",
                true
              )

              flow.run
            end
          end
        end

        context 'when it is creating from a pre-release but there are no changes since the last one' do
          it 'sends a message notifying about the fact that there are no changes to deploy' do
            VCR.use_cassette('flows#pre-release#no-changes') do
              repository = github_repository_with_applications
              repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

              flow = described_class.new(valid_json)

              message_count = 0
              allow_any_instance_of(Clients::Notifications::Channel).to receive(:send) { |_arg| message_count += 1 }

              flow.run
              expect(message_count).to eql(2)
            end
          end
        end

        context 'when it is creating from a pre-release and there are changes since the last one' do
          it 'creates a new version' do
            VCR.use_cassette('flows#pre-release#new-changes') do
              repository = github_repository_with_applications
              repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

              pull_request = FactoryBot.create(:pull_request, repository:)

              FactoryBot.create(:commit, {
                                  message: 'commit number three',
                                  pull_request:
                                })

              flow = described_class.new(valid_json)

              expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
                github_repository_with_applications,
                'rc.2.v1.0.0',
                'master',
                "Available in the release of *roadrunner-repository-test*:\n - commit number three",
                true
              )

              flow.run
            end
          end
        end

        context 'when the pull request has a jira link in it' do
          it 'shows the jira link in the message' do
            VCR.use_cassette('flows#pre-release#new-changes') do
              repository = github_repository_with_applications
              repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

              pull_request = FactoryBot.create(:pull_request, {
                                                 title: 'PR: Update .env 4',
                                                 description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                                 repository:
                                               })

              FactoryBot.create(:commit, {
                                  message: 'commit number three',
                                  pull_request:
                                })

              flow = described_class.new(valid_json)

              expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
                github_repository_with_applications,
                'rc.2.v1.0.0',
                'master',
                "Available in the release of *roadrunner-repository-test*:\n - commit number three [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)",
                true
              )

              flow.run
            end
          end
        end
      end

      context 'When the repository belongs to Azure' do
        include_context 'mock backstage azure'
        let(:azure_repository_with_applications) do
          repository = FactoryBot.create(:repository, owner: 'Avant', name: 'roadrunner-repository-test',
                                                      source_control_type: 'azure')
          repository.applications << FactoryBot.create(:application, repository:, environment: 'qa')
          repository
        end

        context 'when it is the first pre-release' do
          it 'creates the first pre-release' do
            VCR.use_cassette('flows#azure#pre-release#first') do
              repository = azure_repository_with_applications
              repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

              pull_request = FactoryBot.create(:pull_request, repository:)

              FactoryBot.create(:commit, {
                                  message: 'commit number one',
                                  pull_request:
                                })

              FactoryBot.create(:commit, {
                                  message: 'commit number two',
                                  pull_request:
                                })

              flow = described_class.new(valid_json)

              expect_any_instance_of(Clients::Azure::Release).to receive(:create).with(
                azure_repository_with_applications,
                'rc.1.v1.0.0',
                'master',
                "Available in the release of *roadrunner-repository-test*:\n - commit number one \n - commit number two",
                true
              )

              flow.run
            end
          end
        end

        context 'when it is creating from a pre-release but there are no changes since the last one' do
          it 'sends a message notifying about the fact that there are no changes to deploy' do
            VCR.use_cassette('flows#azure#pre-release#no-changes') do
              repository = azure_repository_with_applications
              repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

              flow = described_class.new(valid_json)

              message_count = 0
              allow_any_instance_of(Clients::Notifications::Channel).to receive(:send) { |_arg| message_count += 1 }

              flow.run
              expect(message_count).to eql(2)
            end
          end
        end

        context 'when it is creating from a pre-release and there are changes since the last one' do
          it 'creates a new version' do
            VCR.use_cassette('flows#azure#pre-release#new-changes') do
              repository = azure_repository_with_applications
              repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

              pull_request = FactoryBot.create(:pull_request, repository:)

              FactoryBot.create(:commit, {
                                  message: 'commit number seven',
                                  pull_request:
                                })

              flow = described_class.new(valid_json)

              expect_any_instance_of(Clients::Azure::Release).to receive(:create).with(
                azure_repository_with_applications,
                'rc.2.v1.1.0',
                'master',
                "Available in the release of *roadrunner-repository-test*:\n - commit number seven",
                true
              )

              flow.run
            end
          end
        end

        context 'when the pull request has a jira link in it' do
          it 'shows the jira link in the message' do
            VCR.use_cassette('flows#azure#pre-release#new-changes') do
              repository = azure_repository_with_applications
              repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

              pull_request = FactoryBot.create(:pull_request, {
                                                 title: 'PR: Update .env 4',
                                                 description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                                 repository:
                                               })

              FactoryBot.create(:commit, {
                                  message: 'commit number seven',
                                  pull_request:
                                })

              flow = described_class.new(valid_json)

              expect_any_instance_of(Clients::Azure::Release).to receive(:create).with(
                azure_repository_with_applications,
                'rc.2.v1.1.0',
                'master',
                "Available in the release of *roadrunner-repository-test*:\n - commit number seven [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)",
                true
              )

              flow.run
            end
          end
        end
      end
    end
  end
end

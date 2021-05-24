# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

# We need to use the Flows::ReleaseFlow since it prepares the execution of the StableReleaseFlow
RSpec.describe Flows::ReleaseFlow, type: :service do
  around do |example|
    ClimateControl.modify SLACK_API_URL: 'https://slack-api.codelitt.dev' do
      example.run
    end
  end

  let(:valid_json) do
    {
      text: 'update prod',
      channel_name: 'feed-test-automations'
    }
  end

  context 'when the repository type is Github' do
    let(:github_repository_with_applications) do
      repository = FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-repository-test', source_control_type: 'github')
      repository.applications << FactoryBot.create(:application, repository: repository, environment: 'prod')
      repository
    end

    describe '#run' do
      context 'when it is the first pre-release' do
        it 'creates a new stable release tag from a pre release version' do
          VCR.use_cassette('flows#stable-release#first') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pull_request = FactoryBot.create(:pull_request, repository: repository)

            FactoryBot.create(:commit, message: 'commit number one', pull_request: pull_request)
            FactoryBot.create(:commit, message: 'commit number two', pull_request: pull_request)
            FactoryBot.create(:commit, message: 'commit number three', pull_request: pull_request)

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              github_repository_with_applications,
              'v1.0.0',
              'ec6d8514475be4eea67446e02365f479a789a5d4',
              "Available in the release of *roadrunner-repository-test*:\n - commit number one \n - commit number two \n - commit number three",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run
          end
        end

        it 'updates the application version' do
          VCR.use_cassette('flows#stable-release#first') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pull_request = FactoryBot.create(:pull_request, repository: repository)

            FactoryBot.create(:commit, pull_request: pull_request)

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create)

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            prod_application = repository.application_by_environment('prod').reload

            flow.run

            expect(prod_application.latest_release.version).to eql('v1.0.0')
          end
        end

        it 'adds commits to release' do
          VCR.use_cassette('flows#stable-release#first') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pull_request = FactoryBot.create(:pull_request, repository: repository)
            FactoryBot.create(:commit, message: 'commit number one', pull_request: pull_request)
            FactoryBot.create(:commit, message: 'commit number two', pull_request: pull_request)
            FactoryBot.create(:commit, message: 'commit number three', pull_request: pull_request)

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create)

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run
            prod_application = repository.application_by_environment('prod').reload
            expect(prod_application.latest_release.commits.count).to eq(3)
          end
        end
      end

      # @TODO: I believe this test may not be checking anything really
      context 'when there are no differences from the latest release' do
        it 'sends a message about it' do
          VCR.use_cassette('flows#stable-release#no-changes') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            message_count = 0
            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

            flow.run
            expect(message_count).to eql(2)
          end
        end
      end

      context 'when it is the second release' do
        it 'creates the release' do
          VCR.use_cassette('flows#stable-release#new-changes') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, repository: repository)

            FactoryBot.create(:commit, message: 'commit number four', pull_request: pr1)
            FactoryBot.create(:commit, message: 'commit number five', pull_request: pr1)
            FactoryBot.create(:commit, message: 'commit number 6', pull_request: pr1)

            pr2 = FactoryBot.create(:pull_request, repository: repository)

            FactoryBot.create(:commit, message: 'commit number seven', pull_request: pr2)

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              github_repository_with_applications,
              'v1.1.0',
              'f6e390ce82c76adb083a80d93620a0d0cdd02fc5',
              "Available in the release of *roadrunner-repository-test*:\n - commit number four \n - commit number five \n - commit number 6 \n - commit number seven",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run
          end
        end
      end
    end
  end

  context 'when the repository type is Azure' do
    let(:azure_repository_with_applications) do
      repository = FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-repository-test', source_control_type: 'azure')
      repository.applications << FactoryBot.create(:application, repository: repository, environment: 'prod')
      repository
    end

    describe '#run' do
      context 'when it is the first pre-release' do
        it 'creates a new stable release tag from a pre release version' do
          VCR.use_cassette('flows#azure#stable-release#first') do
            repository = azure_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pull_request = FactoryBot.create(:pull_request, repository: repository)

            FactoryBot.create(:commit, message: 'commit number one', pull_request: pull_request)
            FactoryBot.create(:commit, message: 'commit number two', pull_request: pull_request)
            FactoryBot.create(:commit, message: 'commit number three', pull_request: pull_request)

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Azure::Release).to receive(:create).with(
              azure_repository_with_applications,
              'v1.0.0',
              '6386d66dbc96076897ade78021bb91cb94f40972',
              "Available in the release of *roadrunner-repository-test*:\n - commit number one \n - commit number two \n - commit number three",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run
          end
        end

        it 'updates the application version' do
          VCR.use_cassette('flows#azure#stable-release#first') do
            repository = azure_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pull_request = FactoryBot.create(:pull_request, repository: repository)

            FactoryBot.create(:commit, pull_request: pull_request)

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Azure::Release).to receive(:create)

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            prod_application = repository.application_by_environment('prod').reload

            flow.run

            expect(prod_application.latest_release.version).to eql('v1.0.0')
          end
        end

        it 'adds commits to release' do
          VCR.use_cassette('flows#azure#stable-release#first') do
            repository = azure_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pull_request = FactoryBot.create(:pull_request, repository: repository)
            FactoryBot.create(:commit, message: 'commit number one', pull_request: pull_request)
            FactoryBot.create(:commit, message: 'commit number two', pull_request: pull_request)
            FactoryBot.create(:commit, message: 'commit number three', pull_request: pull_request)

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Azure::Release).to receive(:create)

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run
            prod_application = repository.application_by_environment('prod').reload
            expect(prod_application.latest_release.commits.count).to eq(3)
          end
        end
      end

      # @TODO: I believe this test may not be checking anything really
      context 'when there are no differences from the latest release' do
        it 'sends a message about it' do
          VCR.use_cassette('flows#azure#stable-release#no-changes') do
            repository = azure_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            message_count = 0
            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

            flow.run
            expect(message_count).to eql(2)
          end
        end
      end

      # @TODO: We're currently not bringing all the changes through the Azure::Branch compare method, we need to fix it before we work on this test
      xcontext 'when it is the second release' do
        it 'creates the release' do
          VCR.use_cassette('flows#azure#stable-release#new-changes') do
            repository = azure_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, repository: repository)

            FactoryBot.create(:commit, message: 'commit number four', pull_request: pr1)
            FactoryBot.create(:commit, message: 'commit number five', pull_request: pr1)
            FactoryBot.create(:commit, message: 'commit number 6', pull_request: pr1)

            pr2 = FactoryBot.create(:pull_request, repository: repository)

            FactoryBot.create(:commit, message: 'commit number seven', pull_request: pr2)

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Azure::Release).to receive(:create).with(
              azure_repository_with_applications,
              'v1.1.0',
              '14442b5cfdf65531211250b7a7427b0250b64fc1',
              "Available in the release of *roadrunner-repository-test*:\n - commit number four \n - commit number five \n - commit number 6 \n - commit number seven",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run
          end
        end
      end
    end
  end
end

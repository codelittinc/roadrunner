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

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .gitignore',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Create .gitignore',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-07-24 12:08:07 UTC')
                              })

            pr2 = FactoryBot.create(:pull_request, {
                                      title: 'Create README.md',
                                      description: 'Card:',
                                      repository: repository,
                                      source_control_id: 123
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Creating the README.md file',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-07-24 11:26:10 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              github_repository_with_applications,
              'v1.0.0',
              '89374111e03f9c111cbff83c941d80b4d1a8c019',
              "Available in the release of *roadrunner-repository-test*:\n - Creating the README.md file \n - Create .gitignore",
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

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .gitignore',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Create .gitignore',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-07-24 12:08:07 UTC')
                              })

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
      end

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

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .env.example',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075esssa6779f876442649f55',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 20:43:21 UTC')
                              })

            pr2 = FactoryBot.create(:pull_request, {
                                      title: 'Create README.md',
                                      description: 'Card:',
                                      repository: repository,
                                      source_control_id: 123
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Update README.md',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-08-28 20:43:21 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              github_repository_with_applications,
              'v1.1.0',
              'bc1f53d9bb8818665e5fafc393219023f839bec6',
              "Available in the release of *roadrunner-repository-test*:\n - Update README.md",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run
          end
        end

        it 'updates the application version' do
          VCR.use_cassette('flows#stable-release#new-changes') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .env.example',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075esssa6779f876442649f55',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 20:43:21 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create)

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run

            prod_application = repository.application_by_environment('prod').reload
            expect(prod_application.latest_release.version).to eql('v1.1.0')
          end
        end

        it 'add commits to release' do
          VCR.use_cassette('flows#stable-release#new-changes') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .env.example',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075esssa6779f876442649f55',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 20:43:21 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create)

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.run
            prod_application = repository.application_by_environment('prod').reload
            expect(prod_application.latest_release.commits.count).to eq(1)
          end
        end
      end

      context 'when there are four commits' do
        it 'uses the latest to create the tag' do
          VCR.use_cassette('flows#stable-release#many-commits') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 4',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '2c6dd08ba0bdf065b7351255afa793f0e5784f25',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 21:05:26 UTC')
                              })

            FactoryBot.create(:commit, {
                                sha: '2c6dd08ba0bdf065b7351255afa793f0e5784f25',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 21:05:26 UTC')
                              })

            pr2 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 3',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                      repository: repository,
                                      source_control_id: 123
                                    })

            FactoryBot.create(:commit, {
                                sha: 'be6cdfeec05baaf93aba94244b98707e94199761',
                                message: 'Update README.md',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-08-10 21:05:26 UTC')
                              })

            pr3 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 1',
                                      description: 'Change 1',
                                      repository: repository,
                                      source_control_id: 124
                                    })

            FactoryBot.create(:commit, {
                                sha: '59254c02079408178f40b12e8192d945988d9644',
                                message: 'Update README.md',
                                pull_request: pr3,
                                created_at: DateTime.parse('2020-08-28 14:50:22 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              github_repository_with_applications,
              'v1.2.0',
              '59254c02079408178f40b12e8192d945988d9644',
              "Available in the release of *roadrunner-repository-test*:\n - Update README.md [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)",
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

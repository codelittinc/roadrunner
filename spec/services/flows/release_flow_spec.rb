require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::ReleaseFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'release_tag.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'with a valid json' do
      it 'returns true' do
        FactoryBot.create(:repository)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'with a valid json' do
      it 'where the environment is different from qa or prod returns false' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     "text": 'update prodd',
                                     "channel_name": 'feed-test-automations'
                                   })
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    context 'with the qa environment' do
      it 'calls the release candidate subflow' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     "text": 'update qa',
                                     "channel_name": 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.execute
      end

      context 'when it is the first pre-release' do
        it 'creates the first pre-release' do
          VCR.use_cassette('flows#pre-release#first') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            repository = FactoryBot.create(:pull_request, {
                                             title: 'Create README.md',
                                             description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                             repository: repository
                                           })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Creating the README.md file',
                                pull_request: repository,
                                created_at: DateTime.parse('2020-07-24 11:26:10 UTC')
                              })

            flow = described_class.new(valid_json)

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'rc.1.v0.1.0',
              'master',
              "Available in this release *candidate*:\n - Create README.md [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)",
              true
            )

            flow.execute
          end
        end
      end

      context 'when it is creating from a pre-release but there are no changes since the last one' do
        it 'sends a message notifying about the fact that there are no changes to deploy' do
          VCR.use_cassette('flows#pre-release#no-changes') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            repository = FactoryBot.create(:pull_request, {
                                             title: 'Create README.md',
                                             description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                             repository: repository
                                           })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Creating the README.md file',
                                pull_request: repository,
                                created_at: DateTime.parse('2020-07-24 11:26:10 UTC')
                              })

            flow = described_class.new(valid_json)

            message_count = 0
            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

            flow.execute
            expect(message_count).to eql(2)
          end
        end
      end

      context 'when it is creating from a pre-release and there are changes since the last one' do
        it 'creates a new version' do
          VCR.use_cassette('flows#pre-release#new-changes') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            repository = FactoryBot.create(:pull_request, {
                                             title: 'Create .gitignore',
                                             description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-276',
                                             repository: repository
                                           })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Create .gitignore',
                                pull_request: repository,
                                created_at: DateTime.parse('2020-07-24 12:08:07 UTC')
                              })

            flow = described_class.new(valid_json)

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'rc.2.v0.1.0',
              'master',
              "Available in this release *candidate*:\n - Create .gitignore [AYAPI-276](https://codelitt.atlassian.net/browse/AYAPI-276)",
              true
            )

            flow.execute
          end
        end
      end
    end

    context 'with the prod environment' do
      it 'calls the release candidate subflow' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     "text": 'update prod',
                                     "channel_name": 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseStableFlow).to receive(:execute)

        flow.execute
      end

      context 'when it is the first pre-release' do
        it 'creates a new stable release tag from a pre release version' do
          VCR.use_cassette('flows#stable-release#first') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .gitignore',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-276',
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
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Creating the README.md file',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-07-24 11:26:10 UTC')
                              })

            flow = described_class.new({
                                         "text": 'update prod',
                                         "channel_name": 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'v0.1.0',
              '89e6b1bd6e1c531b14b44c71f662395415a0c9df',
              "Available in this release *candidate*:\n - Create README.md [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)\n - Create .gitignore [AYAPI-276](https://codelitt.atlassian.net/browse/AYAPI-276)",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.execute
          end
        end
      end

      context 'when there are no differences from the latest release' do
        it 'sends a message about it' do
          VCR.use_cassette('flows#stable-release#no-changes') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            flow = described_class.new({
                                         "text": 'update prod',
                                         "channel_name": 'feed-test-automations'
                                       })

            message_count = 0
            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

            flow.execute
            expect(message_count).to eql(2)
          end
        end
      end

      context 'when it is the second release' do
        it 'creates the release' do
          VCR.use_cassette('flows#stable-release#new-changes') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .env.example',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-278',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075esssa6779f876442649f55',
                                message: 'Add .env.example',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-07-24 14:50:07 UTC')
                              })

            pr2 = FactoryBot.create(:pull_request, {
                                      title: 'Create README.md',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Creating the README.md file',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-07-24 11:26:10 UTC')
                              })

            flow = described_class.new({
                                         "text": 'update prod',
                                         "channel_name": 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'v0.2.0',
              '3c0adc4453e25ba32b9bac53fa9799f60fb37a21',
              "Available in this release *candidate*:\n - Create .env.example [AYAPI-278](https://codelitt.atlassian.net/browse/AYAPI-278)",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.execute
          end
        end
      end

      context 'when there are four commits' do
        it 'uses the latest to create the tag' do
          VCR.use_cassette('flows#stable-release#many-commits') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 1',
                                      description: 'Change 1',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075esssa6779f876442649f55',
                                message: 'Update .env 1',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-07-24 17:21:04 UTC')
                              })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075esssa6779f876442649f55',
                                message: 'Update .env 2',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-07-24 17:22:40 UTC')
                              })

            pr2 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 3',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Update .env 3',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-07-24 17:23:05 UTC')
                              })

            pr3 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 4',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Update .env 4',
                                pull_request: pr3,
                                created_at: DateTime.parse('2020-07-24 17:25:01 UTC')
                              })

            flow = described_class.new({
                                         "text": 'update prod',
                                         "channel_name": 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'v0.3.0',
              '2c6dd08ba0bdf065b7351255afa793f0e5784f25',
              "Available in this release *candidate*:\n - PR: Update .env 1 \n - PR: Update .env 3 [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)\n - PR: Update .env 4 [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.execute
          end
        end
      end
    end
  end
end

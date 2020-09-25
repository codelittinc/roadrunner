# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'ostruct'

# @TODO: We need to fix the release message, it is not returning the commit messages
RSpec.describe Flows::HotfixReleaseFlow, type: :service do
  around do |example|
    ClimateControl.modify SLACK_API_URL: 'https://slack-api.codelitt.dev/' do
      example.run
    end
  end

  let(:valid_json_qa) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'release_hotfix_qa.json'))).with_indifferent_access
  end

  let(:valid_json_prod) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'release_hotfix_prod.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true' do
      it 'when the json is valid' do
        FactoryBot.create(:repository, name: 'roadrunner-repository-test')
        flow = described_class.new(valid_json_qa)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when the environment is different from qa or prod' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     "text": 'update prodd',
                                     "channel_name": 'feed-test-automations'
                                   })
        expect(flow.flow?).to be_falsey
      end

      it 'when the json is valid, but repository does not exist' do
        flow = described_class.new(valid_json_qa)
        expect(flow.flow?).to be_falsey
      end

      it 'when there is not link between the repository and that slack channel' do
        flow = described_class.new(valid_json_qa)
        expect(flow.flow?).to be_falsey
      end

      it 'when the text message has more than four words' do
        FactoryBot.create(:repository)
        flow = described_class.new({
                                     "text": 'update prod roadrunner-rails test branch',
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
                                     "text": 'hotfix qa roadrunner-repository-test hotfix/fix-to-test',
                                     "channel_name": 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::HotfixReleaseCandidateFlow).to receive(:execute)

        flow.execute
      end

      context 'when there are no changes between the branchs' do
        it 'ensure it does not throw an error' do
          FactoryBot.create(:repository)

          flow = described_class.new({
                                       "text": 'hotfix qa roadrunner-repository-test hotfix/fix-to-test',
                                       "channel_name": 'feed-test-automations'
                                     })

          allow_any_instance_of(Clients::Github::Branch).to receive(:compare).and_return([])
          allow_any_instance_of(Clients::Github::Release).to receive(:list).and_return([OpenStruct.new({ 'tag_name': 'rc.1.v1.1.1' })])
          allow_any_instance_of(Clients::Github::Branch).to receive(:branch_exists?).and_return(true)
          allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

          allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
            'Hey the *QA* environment already has all the latest changes', 'feed-test-automations', '123'
          )

          expect { flow.execute }.to_not raise_error
        end
      end

      it 'creates the first hotfix' do
        VCR.use_cassette('flows#hotfix#first') do
          repository = FactoryBot.create(:repository)
          repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

          FactoryBot.create(:commit, :with_pull_request, {
                              sha: '897bae42f8bcf90bd8676b1ed94e8ba202a6c9ed',
                              message: 'Update README.md',
                              created_at: DateTime.parse('2020-08-31 13:09:19 UTC')
                            })

          flow = described_class.new(valid_json_qa)

          expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
            'codelittinc/roadrunner-repository-test',
            'rc.1.v1.1.1',
            'hotfix/fix-to-test',
            # @TODO: send a proper message in the first hotfix
            "Available in the release of *roadrunner-repository-test*:\n - Update README.md",
            true
          )

          flow.execute
        end
      end

      it 'create the next hotfix if exists another one' do
        VCR.use_cassette('flows#hotfix#create-others-hotfix') do
          repository = FactoryBot.create(:repository)
          repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

          FactoryBot.create(:commit, :with_pull_request, {
                              sha: '68c44076db9827d83f110692690dbbeeb1ca3a7f',
                              message: 'Update README.md',
                              created_at: DateTime.parse('2020-08-31 13:38:33 UTC')
                            })

          flow = described_class.new(valid_json_qa)

          expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
            'codelittinc/roadrunner-repository-test',
            'rc.2.v1.1.1',
            'hotfix/fix-to-test',
            "Available in the release of *roadrunner-repository-test*:\n - Update README.md",
            true
          )

          flow.execute
        end
      end

      context 'when does not exist the branch passed as parameter' do
        it 'sends a message notifying about the fact that there is no branch to deploy' do
          VCR.use_cassette('flows#hotfix#no-branch') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            flow = described_class.new({
                                         "text": 'hotfix qa roadrunner-repository-test hotfix/test',
                                         "channel_name": 'feed-test-automations'
                                       })

            message_count = 0
            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

            flow.execute
            expect(message_count).to eql(2)
          end
        end
      end

      context 'when it is creating from a pre-release but there are no changes since the last one' do
        it 'sends a message notifying about the fact that there are no changes to deploy' do
          VCR.use_cassette('flows#hotfix#no-changes') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            FactoryBot.create(:commit, :with_pull_request, {
                                sha: 'e8226ba00200b0ef0849b3a32578dcc60b9c35b5',
                                message: 'Update README.md',
                                created_at: DateTime.parse('2020-08-23 13:08:10 UTC')
                              })

            flow = described_class.new(valid_json_qa)

            message_count = 0
            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

            flow.execute
            expect(message_count).to eql(2)
          end
        end
      end
    end

    describe 'with the prod environment' do
      it 'calls the release candidate subflow' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     "text": 'hotfix prod roadrunner-repository-test',
                                     "channel_name": 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::HotfixReleaseStableFlow).to receive(:execute)

        flow.execute
      end

      context 'when there is a hotfix QA version at the moment' do
        it 'create a hotfix stable version' do
          VCR.use_cassette('flows#hotfix#create-stable-release') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            FactoryBot.create(:commit, :with_pull_request, {
                                sha: '897bae42f8bcf90bd8676b1ed94e8ba202a6c9ed',
                                message: 'Update README.md',
                                created_at: DateTime.parse('2020-08-31 13:09:19 UTC')
                              })

            flow = described_class.new(valid_json_prod)

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'v1.1.1',
              '897bae42f8bcf90bd8676b1ed94e8ba202a6c9ed',
              "Available in the release of *roadrunner-repository-test*:\n - Update README.md",
              false
            )

            flow.execute
          end
        end
      end

      context 'when there is not hotfix QA version' do
        it 'it should returns nil' do
          VCR.use_cassette('flows#hotfix#handle-stable-hotfix') do
            repository = FactoryBot.create(:repository)
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            flow = described_class.new({
                                         "text": 'hotfix prod roadrunner-repository-test',
                                         "channel_name": 'feed-test-automations'
                                       })

            expect(flow.execute).to be_nil
          end
        end
      end
    end
  end
end

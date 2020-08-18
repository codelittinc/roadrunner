require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::ClosePullRequestFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_close_pull_request.json'))).with_indifferent_access
  end

  let(:cancelled_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_cancel_pull_request.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true when' do
      it 'a pull request exists and it is open' do
        FactoryBot.create(:pull_request, github_id: 13)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'a pull request exists but it is closed' do
        pr = FactoryBot.create(:pull_request, github_id: 13)
        pr.merge!

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request exists but it is cancelled' do
        pr = FactoryBot.create(:pull_request, github_id: 13)
        pr.cancel!

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request does not exist' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    it 'creates a set of commits from the pull request in the database' do
      VCR.use_cassette('flows#close-pull-request#create-commit') do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, github_id: 13, repository: repository, slack_message: slack_message)

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update)

        expect { flow.run }.to change { Commit.count }.by(1)
      end
    end

    it 'creates a set of commits from the pull request in the database with the right message' do
      VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, github_id: 13, repository: repository, slack_message: slack_message)

        expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update)
        flow = described_class.new(valid_json)
        flow.run
        expect(Commit.last.message).to eql('Enable cors')
      end
    end

    it 'sends two jira status update messages when the pull request body has two links' do
      VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, github_id: 13, repository: repository, slack_message: slack_message)

        expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update)

        flow = described_class.new(valid_json)
        message_count = 0
        allow_any_instance_of(Clients::Slack::DirectMessage).to receive(:send_ephemeral) { |_arg| message_count += 1 }

        flow.run
        expect(message_count).to eql(2)
      end
    end

    it 'sends a direct message to the owner of the pull request' do
      VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, github_id: 13, repository: repository, slack_message: slack_message)

        expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update)

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
          ':merge2: Pull Request closed <https://github.com/codelittinc/roadrunner-rails/pull/13|roadrunner-rails#13>', 'kaiomagalhaes'
        )

        flow = described_class.new(valid_json)
        flow.run
      end
    end

    it 'do not send a direct message to the owner of the pull request if it was cancelled' do
      VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, github_id: 13, repository: repository, slack_message: slack_message)

        expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update)

        flow = described_class.new(cancelled_json)
        message_count = 0
        allow_any_instance_of(Clients::Slack::DirectMessage).to receive(:send_ephemeral) { |_arg| message_count += 1 }
        allow_any_instance_of(Clients::Slack::DirectMessage).to receive(:send) { |_arg| message_count += 1 }

        flow.run
        expect(message_count).to eql(0)
      end
    end

    it 'sends a merge reaction if the pr was merged' do
      VCR.use_cassette('flows#close-pull-request#create-commit-right-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, github_id: 13, repository: repository, slack_message: slack_message)

        expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update)

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('merge2', 'feed-test-automations', '123')

        flow.run
      end
    end

    it 'sends a cancel reaction if the pr was cancelled' do
      VCR.use_cassette('flows#close-pull-request#create-commit-right-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, github_id: 13, repository: repository, slack_message: slack_message)

        expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update)

        flow = described_class.new(cancelled_json)

        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('x', 'feed-test-automations', '123')

        flow.run
      end
    end
  end
end

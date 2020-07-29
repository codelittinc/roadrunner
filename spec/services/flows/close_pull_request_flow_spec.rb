require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::ClosePullRequestFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_close_pull_request.json'))).with_indifferent_access
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

  describe '#execute' do
    it 'creates a set of commits from the pull request in the database' do
      VCR.use_cassette('flows#close-pull-request#create-commit') do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, github_id: 13, repository: repository, slack_message: slack_message)

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update)

        expect { flow.execute }.to change { Commit.count }.by(1)
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
        flow.execute
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

        flow.execute
        expect(message_count).to eql(2)
      end
    end
  end
end

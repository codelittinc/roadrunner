# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::NewChangePullRequestCodeFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_change_pull_request.json'))).with_indifferent_access
  end

  let(:closed_pr_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_close_pull_request.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true when' do
      it 'a pull request exists and it is open' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        FactoryBot.create(:pull_request, source_control_id: 1, repository: repository)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'a pull request exists but it is closed' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        pr = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository)
        pr.merge!

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request exists and action is not synchronize' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        FactoryBot.create(:pull_request, source_control_id: 1, repository: repository)

        flow = described_class.new(closed_pr_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request exists and branch name is reserved' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        FactoryBot.create(:pull_request, source_control_id: 1, repository: repository)
        invalid_json = valid_json.deep_dup

        reserved_branch_names = %w[master development develop qa]

        reserved_branch_names.each do |branch_name|
          invalid_json[:pull_request][:head][:ref] = branch_name

          flow = described_class.new(invalid_json)

          expect(flow.flow?).to be_falsey
        end
      end

      it 'a pull request exists but it is cancelled' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        pr = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository)
        pr.cancel!

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request does not exist' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end
    end

    it 'does not throw error for invalid json' do
      flow = described_class.new(JSON.parse('{}'))

      expect { flow.flow? }.to_not raise_error
    end
  end

  describe '#run' do
    it 'sends a message if the pr was changed' do
      VCR.use_cassette('flows#change-pull-request#change-send-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message)

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

        expect { flow.run }.to change { pull_request.pull_request_changes.count }.by(1)
      end
    end

    it 'sends the right message' do
      VCR.use_cassette('flows#change-pull-request#change-send-right-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message)

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          ':pencil2: There is a new change!', 'feed-test-automations', '123'
        )

        expect { flow.run }.to change { pull_request.pull_request_changes.count }.by(1)
      end
    end
  end
end

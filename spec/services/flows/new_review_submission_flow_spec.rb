# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::NewReviewSubmissionFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'new_review_submission_request.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true when' do
      it 'contains a review' do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, source_control_id: 180, slack_message: slack_message, repository: repository, head: 'kaiomagalhaes-patch-121')

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end

      it 'a pull request exists, slack_message exists and action is submitted' do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, source_control_id: 180, slack_message: slack_message, repository: repository, head: 'kaiomagalhaes-patch-121')

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'has an empty json' do
        flow = described_class.new(JSON.parse('{}'))
        expect(flow.flow?).to be_falsey
      end

      it 'a review is empty in json' do
        invalid_json = valid_json.deep_dup
        invalid_json[:review] = JSON.parse('{}')

        flow = described_class.new(invalid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request does not exist in db' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request exists but a slack_message does not' do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        FactoryBot.create(:pull_request, source_control_id: 1, repository: repository)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request exists but an action is not submitted' do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, source_control_id: 1, slack_message: slack_message, repository: repository)
        invalid_json = valid_json.deep_dup
        invalid_json[:action] = 'test'

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'action is not submitted' do
        invalid_json = valid_json.deep_dup
        invalid_json[:action] = 'test'

        flow = described_class.new(invalid_json)
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    it 'sends a message if there is a new review submission' do
      VCR.use_cassette('flows#new-review-submission-request#new-review-send-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, source_control_id: 180, repository: repository, slack_message: slack_message, head: 'kaiomagalhaes-patch-121')

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

        flow.run
      end
    end

    it 'sends the correct direct message' do
      VCR.use_cassette('flows#new-review-submission-request#new-review-send-direct-message', record: :new_episodes) do
        user = FactoryBot.create(:user, slack: 'rheniery.mendes')
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, source_control_id: 180, slack_message: slack_message, user: user, repository: repository, head: 'kaiomagalhaes-patch-121')
        valid_json_direct_message = valid_json.deep_dup
        valid_json_direct_message[:review][:state] = 'test'
        valid_json_direct_message[:review][:body] = ''

        flow = described_class.new(valid_json_direct_message)

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
          ':boom: there are conflicts on this Pull Request: <https://github.com/codelittinc/gh-hooks-repo-test/pull/180|gh-hooks-repo-test#180>', 'rheniery.mendes'
        )

        flow.run
      end
    end

    it 'sends the correct channel message when there are changes requested' do
      VCR.use_cassette('flows#new-review-submission-request#new-review-send-channel-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, source_control_id: 180, repository: repository, slack_message: slack_message, head: 'kaiomagalhaes-patch-121')
        valid_json_channel_changes = valid_json.deep_dup
        valid_json_channel_changes[:review][:state] = 'changes_requested'

        flow = described_class.new(valid_json_channel_changes)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          ':warning: changes requested!', 'feed-test-automations', '123'
        )

        flow.run
      end
    end

    it 'sends the correct channel message when there is a message on review without mentions' do
      VCR.use_cassette('flows#new-review-submission-request#new-review-send-channel-message-with-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        FactoryBot.create(:pull_request, source_control_id: 180, repository: repository, slack_message: slack_message, head: 'kaiomagalhaes-patch-121')
        valid_json_channel_message = valid_json.deep_dup
        valid_json_channel_message[:review][:state] = 'test'
        valid_json_channel_message[:review][:message] = 'I sent a message'

        flow = described_class.new(valid_json_channel_message)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          ':speech_balloon: There is a new message!', 'feed-test-automations', '123'
        )

        flow.run
      end
    end
  end
end

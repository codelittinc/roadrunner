# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Flows::NewReviewSubmissionFlow, type: :service do
  context 'Github JSON' do
    let(:valid_json) { load_flow_fixture('new_review_submission_request.json') }
    let(:repository) { FactoryBot.create(:repository, name: 'gh-hooks-repo-test') }

    describe '#flow?' do
      context 'returns true when' do
        it 'contains a review' do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 180, slack_message:,
                                           repository:, head: 'kaiomagalhaes-patch-121')

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end

        it 'a pull request exists, slack_message exists and action is submitted' do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 180, slack_message:,
                                           repository:, head: 'kaiomagalhaes-patch-121')

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
          FactoryBot.create(:pull_request, source_control_id: 1, repository:)

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request exists but an action is not submitted' do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 1, slack_message:, repository:)
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
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 180, repository:,
                                           slack_message:, head: 'kaiomagalhaes-patch-121')

          flow = described_class.new(valid_json)

          expect_any_instance_of(Clients::Slack::Channel).to receive(:send)

          flow.run
        end
      end

      it 'sends the correct direct message' do
        VCR.use_cassette('flows#new-review-submission-request#new-review-send-direct-message', record: :new_episodes) do
          user = FactoryBot.create(:user, slack: 'rheniery.mendes')
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 180, slack_message:, user:,
                                           repository:, head: 'kaiomagalhaes-patch-121')
          valid_json_direct_message = valid_json.deep_dup
          valid_json_direct_message[:review][:state] = 'test'
          valid_json_direct_message[:review][:body] = ''

          flow = described_class.new(valid_json_direct_message)

          expect_any_instance_of(Clients::Slack::Direct).to receive(:send).with(
            ':boom: there are conflicts on this Pull Request: <https://github.com/codelittinc/gh-hooks-repo-test/pull/180|gh-hooks-repo-test#180>', 'rheniery.mendes'
          )

          flow.run
        end
      end

      it 'does not send a message if the user does not have a slack username' do
        VCR.use_cassette('flows#new-review-submission-request#new-review-send-direct-message', record: :new_episodes) do
          user = FactoryBot.create(:user, slack: nil)
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 180, slack_message:, user:,
                                           repository:, head: 'kaiomagalhaes-patch-121')
          valid_json_direct_message = valid_json.deep_dup
          valid_json_direct_message[:review][:state] = 'test'
          valid_json_direct_message[:review][:body] = ''

          flow = described_class.new(valid_json_direct_message)

          expect_any_instance_of(Clients::Slack::Direct).to_not receive(:send)

          flow.run
        end
      end

      it 'sends the correct channel message when there are changes requested' do
        VCR.use_cassette('flows#new-review-submission-request#new-review-send-channel-message',
                         record: :new_episodes) do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 180, repository:,
                                           slack_message:, head: 'kaiomagalhaes-patch-121')
          valid_json_channel_changes = valid_json.deep_dup
          valid_json_channel_changes[:review][:state] = 'changes_requested'

          flow = described_class.new(valid_json_channel_changes)

          expect_any_instance_of(Clients::Slack::Channel).to receive(:send).with(
            ':warning: changes requested!', 'feed-test-automations', '123'
          )

          flow.run
        end
      end

      it 'sends the correct channel message when there is a message on review without mentions' do
        VCR.use_cassette('flows#new-review-submission-request#new-review-send-channel-message-with-message',
                         record: :new_episodes) do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 180, repository:,
                                           slack_message:, head: 'kaiomagalhaes-patch-121')
          valid_json_channel_message = valid_json.deep_dup
          valid_json_channel_message[:review][:state] = 'test'
          valid_json_channel_message[:review][:message] = 'I sent a message'

          flow = described_class.new(valid_json_channel_message)

          expect_any_instance_of(Clients::Slack::Channel).to receive(:send).with(
            ':speech_balloon: There is a new message!', 'feed-test-automations', '123'
          )

          flow.run
        end
      end
    end
  end

  context 'Azure JSON' do
    let(:valid_json) { load_flow_fixture('azure_new_review_submission_request.json') }
    let(:repository) { FactoryBot.create(:repository, name: 'ay-pia-web', owner: 'Avant') }

    describe '#flow?' do
      context 'returns true when' do
        it 'contains a review' do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 357, slack_message:,
                                           repository:, head: 'kaiomagalhaes-patch-121')

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'returns false when' do
        it 'has an empty json' do
          flow = described_class.new(JSON.parse('{}'))
          expect(flow.flow?).to be_falsey
        end

        it 'a comment is empty in json' do
          invalid_json = valid_json.deep_dup
          invalid_json[:comment] = JSON.parse('{}')

          flow = described_class.new(invalid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request does not exist in db' do
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request exists but a slack_message does not' do
          pull_request = FactoryBot.create(:pull_request, source_control_id: 357, repository:)
          pull_request.slack_message.destroy!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request exists but the event type is invalid' do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 357, slack_message:, repository:)
          invalid_json = valid_json.deep_dup
          invalid_json[:eventType] = 'test'

          flow = described_class.new(invalid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'event type is invalid' do
          invalid_json = valid_json.deep_dup
          invalid_json[:eventType] = 'test'

          flow = described_class.new(invalid_json)
          expect(flow.flow?).to be_falsey
        end
      end
    end
    describe '#run' do
      it 'sends a message if there is a new review submission' do
        VCR.use_cassette('flows#new-review-submission-request#azure#new-review-send-message', record: :new_episodes) do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 357, repository:,
                                           slack_message:, head: 'kaiomagalhaes-patch-121', source_control_type: 'azure')

          flow = described_class.new(valid_json)

          expect_any_instance_of(Clients::Slack::Channel).to receive(:send).with(
            ':speech_balloon: There is a new message!', 'feed-test-automations', '123'
          )

          flow.run
        end
      end

      # @TODO: fix these tests
      # it 'sends the correct channel message when there are changes requested' do
      #  VCR.use_cassette('flows#new-review-submission-request#new-review-send-channel-message', record: :new_episodes) do
      #    slack_message = FactoryBot.create(:slack_message, ts: '123')
      #    FactoryBot.create(:pull_request, source_control_id: 357, repository: repository, slack_message: slack_message, head: 'kaiomagalhaes-patch-121', source_control_type: 'azure')
      #    valid_json_channel_changes = valid_json.deep_dup

      #    flow = described_class.new(valid_json_channel_changes)

      #    expect_any_instance_of(Clients::Slack::Channel).to receive(:send).with(
      #      ':warning: changes requested!', 'feed-test-automations', '123'
      #    )

      #    flow.run
      #  end
      # end

      # it 'sends the correct channel message when there is a message on review without mentions' do
      #  VCR.use_cassette('flows#new-review-submission-request#new-review-send-channel-message-with-message', record: :new_episodes) do
      #    slack_message = FactoryBot.create(:slack_message, ts: '123')
      #    FactoryBot.create(:pull_request, source_control_id: 180, repository: repository, slack_message: slack_message, head: 'kaiomagalhaes-patch-121')
      #    valid_json_channel_message = valid_json.deep_dup
      #    valid_json_channel_message[:review][:state] = 'test'
      #    valid_json_channel_message[:review][:message] = 'I sent a message'

      #    flow = described_class.new(valid_json_channel_message)

      #    expect_any_instance_of(Clients::Slack::Channel).to receive(:send).with(
      #      ':speech_balloon: There is a new message!', 'feed-test-automations', '123'
      #    )

      #    flow.run
      #  end
      # end
    end
  end
end

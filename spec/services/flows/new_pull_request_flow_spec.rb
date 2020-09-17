# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::NewPullRequestFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_new_pull_request.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true' do
      it 'when it has the opened action and does not exist the pull request in database' do
        valid_json_confirmed = valid_json.deep_dup
        valid_json_confirmed[:number] = 1
        valid_json_confirmed[:action] = 'opened'
        flow = described_class.new(valid_json_confirmed)
        expect(flow.flow?).to be_truthy
      end

      it 'when it has the ready_for_review action and does not exist the pull request in database' do
        valid_json_confirmed = valid_json.deep_dup
        valid_json_confirmed[:number] = 1
        valid_json_confirmed[:action] = 'ready_for_review'
        flow = described_class.new(valid_json_confirmed)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'return false when' do
      it 'when the action is different from opened or ready_for_review' do
        invalid_json = valid_json.deep_dup
        invalid_json[:action] = 'dfsdfsdf'
        flow = described_class.new(invalid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'pull request already exists in database' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        FactoryBot.create(:pull_request, repository: repository, github_id: 160)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    it 'creates a PullRequest in the database' do
      FactoryBot.create(:repository, name: 'roadrunner-rails')

      expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                            'ts' => '123'
                                                                                          })
      expect_any_instance_of(Clients::Slack::Reactji).to receive(:send)
      flow = described_class.new(valid_json)

      expect { flow.run }.to change { PullRequest.count }.by(1)
    end

    it 'creates a SlackMessage in the database' do
      FactoryBot.create(:repository, name: 'roadrunner-rails')

      expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                            'ts' => '123'
                                                                                          })
      expect_any_instance_of(Clients::Slack::Reactji).to receive(:send)

      flow = described_class.new(valid_json)

      expect { flow.run }.to change { SlackMessage.count }.by(1)
    end

    context 'when there is a check run linked with the branch of the pull request' do
      it 'and it state is success, sends a success reaction' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
        FactoryBot.create(:check_run, state: 'success', branch: branch)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              'ts' => '123'
                                                                                            })
        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('white_check_mark', 'feed-test-automations', '123')

        flow = described_class.new(valid_json)

        flow.run
      end

      it 'and it state is failure, sends a failure reaction' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
        FactoryBot.create(:check_run, state: 'failure', branch: branch)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              'ts' => '123'
                                                                                            })
        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('rotating_light', 'feed-test-automations', '123')

        flow = described_class.new(valid_json)

        flow.run
      end

      it 'and it state is pending, sends a pending reaction' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
        FactoryBot.create(:check_run, state: 'pending', branch: branch)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              'ts' => '123'
                                                                                            })
        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('hourglass', 'feed-test-automations', '123')

        flow = described_class.new(valid_json)

        flow.run
      end
    end

    context 'when there is not a check run linked with the branch of the pull request' do
      it 'sends a pending reaction' do
        FactoryBot.create(:repository, name: 'roadrunner-rails')

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              'ts' => '123'
                                                                                            })
        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('hourglass', 'feed-test-automations', '123')

        flow = described_class.new(valid_json)

        flow.run
      end
    end
  end
end

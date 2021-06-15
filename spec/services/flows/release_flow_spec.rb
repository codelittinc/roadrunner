# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Flows::ReleaseFlow, type: :service do
  around do |example|
    ClimateControl.modify NOTIFICATIONS_API_URL: 'https://slack-api.codelitt.dev' do
      example.run
    end
  end

  let(:valid_json) { load_flow_fixture('release_tag.json') }

  let(:repository) do
    FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-repository-test')
  end

  describe '#flow?' do
    context 'returns true' do
      it 'when the json is valid' do
        repository
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when the environment is different from qa or prod' do
        repository

        flow = described_class.new({
                                     text: 'update prodd',
                                     channel_name: 'feed-test-automations'
                                   })
        expect(flow.flow?).to be_falsey
      end

      it 'when the json is valid, but repository does not exist' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'when there is more than one repository tied to that slack channel' do
        repository
        FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-repository-test')

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'when the text message has more than two words' do
        repository
        flow = described_class.new({
                                     text: 'update prod roadrunner-rails',
                                     channel_name: 'feed-test-automations'
                                   })
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    context 'with the qa environment' do
      it 'sends a start release notification to the channel' do
        repository

        flow = described_class.new({
                                     text: 'update qa',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          'Update release to *roadrunner-repository-test* *QA* triggered by @', 'feed-test-automations'
        )
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.run
      end

      it 'calls the release candidate subflow' do
        repository

        flow = described_class.new({
                                     text: 'update qa',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.run
      end
    end

    context 'with the prod environment' do
      it 'sends a start release notification to the channel' do
        repository

        flow = described_class.new({
                                     text: 'update prod',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          'Update release to *roadrunner-repository-test* *PROD* triggered by @', 'feed-test-automations'
        )
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseStableFlow).to receive(:execute)

        flow.run
      end

      it 'calls the release candidate subflow' do
        repository

        flow = described_class.new({
                                     text: 'update prod',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseStableFlow).to receive(:execute)

        flow.run
      end
    end
  end
end

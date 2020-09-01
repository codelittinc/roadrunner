require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::ReleaseBySlackChannelFlow, type: :service do
  around do |example|
    ClimateControl.modify SLACK_API_URL: 'https://slack-api.codelitt.dev' do
      example.run
    end
  end

  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'release_by_slack_channel.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true' do
      it 'when the json is valid' do
        repository = FactoryBot.create(:repository)
        FactoryBot.create(:slack_repository_info, repository: repository)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when the environment is different from qa or prod' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     "text": 'update all prodd',
                                     "channel_name": 'feed-test-automations'
                                   })

        expect(flow.flow?).to be_falsey
      end

      it 'when the text words number is different from three' do
        FactoryBot.create(:repository)
        flow = described_class.new({
                                     "text": 'update prod',
                                     "channel_name": 'feed-test-automations'
                                   })
        expect(flow.flow?).to be_falsey
      end

      it 'when the channel_name does not exist' do
        FactoryBot.create(:repository)
        flow = described_class.new({
                                     "text": 'update prod',
                                     "channel_name": 'feed-test-test'
                                   })
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    context 'with the qa environment' do
      it 'calls the release candidate subflow' do
        repository = FactoryBot.create(:repository)
        repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

        flow = described_class.new({
                                     "text": 'update all qa',
                                     "channel_name": 'feed-test-automations'
                                   })
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.execute
      end
    end

    context 'with the prod environment' do
      it 'calls the release stable subflow' do
        repository = FactoryBot.create(:repository)
        repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

        flow = described_class.new({
                                     "text": 'update all prod',
                                     "channel_name": 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseStableFlow).to receive(:execute)

        flow.execute
      end
    end
  end
end

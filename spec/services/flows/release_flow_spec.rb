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

        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.execute
      end
    end

    context 'with the prod environment' do
      it 'calls the release candidate subflow' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     "text": 'update prod',
                                     "channel_name": 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseStableFlow).to receive(:execute)

        flow.execute
      end
    end

    xit 'creates a new pre-release tag from a stable version' do
      VCR.use_cassette('flows#pre-release') do
        repository = FactoryBot.create(:repository)
        repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

        repository = FactoryBot.create(:pull_request, {
                                         title: 'Add leaseExpirationSized rest of expirations value',
                                         description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                         repository: repository
                                       })

        FactoryBot.create(:commit, {
                            sha: '6a65601c32c1915075e800a6779f876442649f55',
                            message: 'test 1',
                            pull_request: repository
                          })

        FactoryBot.create(:commit, {
                            sha: '06f11bf4f0d5485b048004003a8baa3e9094fe8a',
                            message: 'test 2',
                            pull_request: repository
                          })

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
          'codelittinc/test-gh-notifications',
          'rc.10.v0.0.29',
          'master',
          "Available in this release *candidate*:\n",
          true
        )

        flow.execute
      end
    end

    it 'creates a new stable release tag from a pre release version' do
      VCR.use_cassette('flows#stable-release') do
        repository = FactoryBot.create(:repository)
        repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

        repository = FactoryBot.create(:pull_request, {
                                         title: 'Add leaseExpirationSized rest of expirations value',
                                         description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                         repository: repository
                                       })

        FactoryBot.create(:commit, {
                            sha: '6a65601c32c1915075e800a6779f876442649f55',
                            message: 'Update README.md',
                            pull_request: repository
                          })

        FactoryBot.create(:commit, {
                            sha: '06f11bf4f0d5485b048004003a8baa3e9094fe8a',
                            message: 'test 2',
                            pull_request: repository
                          })

        flow = described_class.new({
                                     "text": 'update prod',
                                     "channel_name": 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
          'codelittinc/test-gh-notifications',
          'v0.0.29',
          '1418d1eb18b54610ca0bc67f21bef8312c9c6101',
          "Available in this release *candidate*:\n",
          false
        )

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

        flow.execute
      end
    end
  end
end

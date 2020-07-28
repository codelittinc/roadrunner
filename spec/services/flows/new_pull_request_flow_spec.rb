require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::NewPullRequestFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_new_pull_request.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'when it has the opened action' do
      it 'returns true ' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end
  end

  describe '#execute' do
    it 'creates a PullRequest in the database' do
      FactoryBot.create(:repository, name: 'roadrunner-rails')

      expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                            'ts' => '123'
                                                                                          })
      flow = described_class.new(valid_json)

      expect { flow.execute }.to change { PullRequest.count }.by(1)
    end

    it 'creates a SlackMessage in the database' do
      FactoryBot.create(:repository, name: 'roadrunner-rails')

      expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                            'ts' => '123'
                                                                                          })
      flow = described_class.new(valid_json)

      expect { flow.execute }.to change { SlackMessage.count }.by(1)
    end
  end
end

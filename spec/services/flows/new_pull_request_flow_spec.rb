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
      flow = described_class.new(valid_json)

      expect { flow.run }.to change { PullRequest.count }.by(1)
    end

    it 'creates a SlackMessage in the database' do
      FactoryBot.create(:repository, name: 'roadrunner-rails')

      expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                            'ts' => '123'
                                                                                          })
      flow = described_class.new(valid_json)

      expect { flow.run }.to change { SlackMessage.count }.by(1)
    end
  end
end

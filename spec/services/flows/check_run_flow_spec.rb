require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::CheckRunFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_check_run_failure.json'))).with_indifferent_access
  end

  describe '#flow?' do
    before(:each) do
      repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
      slack_message = FactoryBot.create(:slack_message, ts: '123')
      user = FactoryBot.create(:user, slack: 'rheniery.mendes')
      pull_request = FactoryBot.create(:pull_request, github_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'develop')
      FactoryBot.create(:commit, sha: '1', pull_request: pull_request)
    end

    context 'returns true when' do
      it 'a check run contains commit' do
        valid_json_with_commit = valid_json.deep_dup

        valid_json_with_commit[:commit] = {
          "sha": 'testing'
        }

        flow = described_class.new(valid_json_with_commit)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains more than 0 branches' do
        valid_json_with_branches = valid_json.deep_dup

        valid_json_with_branches[:branches] = [{
          "name": 'develop'
        }]

        flow = described_class.new(valid_json_with_branches)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains state eqls failure' do
        valid_json_with_state_failure = valid_json.deep_dup

        valid_json_with_state_failure[:state] = 'failure'

        flow = described_class.new(valid_json_with_state_failure)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains state eqls pending' do
        valid_json_with_state_pending = valid_json.deep_dup

        valid_json_with_state_pending[:state] = 'pending'

        flow = described_class.new(valid_json_with_state_pending)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains state eqls success' do
        valid_json_with_state_success = valid_json.deep_dup

        valid_json_with_state_success[:state] = 'success'

        flow = described_class.new(valid_json_with_state_success)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains commit and state eqls success, failure or pending' do
        flow = described_class.new(valid_json)

        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'a check run doesnt contains a commit' do
        invalid_json = valid_json.deep_dup
        invalid_json[:commit] = nil

        flow = described_class.new(invalid_json)

        expect(flow.flow?).to be_falsey
      end

      it 'a check run doesnt contains branches' do
        invalid_json = valid_json.deep_dup
        invalid_json[:branches] = []

        flow = described_class.new(invalid_json)

        expect(flow.flow?).to be_falsey
      end

      it 'a check run has state different of success, failure or pending' do
        invalid_json = valid_json.deep_dup
        invalid_json[:state] = 'test'

        flow = described_class.new(invalid_json)

        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    it 'sends a message if the check run is correct' do
      VCR.use_cassette('flows#check-run#check-run-send-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        user = FactoryBot.create(:user, slack: 'rheniery.mendes')
        pull_request = FactoryBot.create(:pull_request, github_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'develop')
        FactoryBot.create(:commit, sha: '1', pull_request: pull_request)

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send)

        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send)

        flow.execute
      end
    end

    it 'sends the right message' do
      VCR.use_cassette('flows#check-run#check-run-send-right-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        user = FactoryBot.create(:user, slack: 'rheniery.mendes')
        pull_request = FactoryBot.create(:pull_request, github_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'develop')
        FactoryBot.create(:commit, sha: '1', pull_request: pull_request)
        FactoryBot.create(:check_run, state: 'failure')

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(':rotating_light: CI failed for pull request: <https://github.com/codelittinc/roadrunner-rails/pull/1|roadrunner-rails#1>', 'rheniery.mendes')
        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('rotating_light', 'feed-test-automations', '123')

        flow.execute
      end
    end
  end
end

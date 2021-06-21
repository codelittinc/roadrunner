# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Flows::CheckRunFlow, type: :service do
  around do |example|
    ClimateControl.modify NOTIFICATIONS_API_URL: 'https://slack-api.codelitt.dev' do
      example.run
    end
  end

  let(:valid_json) { load_flow_fixture('github_check_run.json') }

  describe '#flow?' do
    before(:each) do
      repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
      slack_message = FactoryBot.create(:slack_message, ts: '123')
      user = FactoryBot.create(:user, slack: 'rheniery.mendes')
      pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'develop')
      FactoryBot.create(:commit, sha: '1', pull_request: pull_request)
    end

    context 'returns true when' do
      it 'a check run contains commit sha' do
        valid_json_with_commit = valid_json.deep_dup

        valid_json_with_commit[:check_run][:head_sha] = '8bdc18cc18ea9d7f4a19d2424171e8aa6e8f8f72'

        flow = described_class.new(valid_json_with_commit)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains branch' do
        valid_json_with_branches = valid_json.deep_dup

        valid_json_with_branches[:check_run][:check_suite][:head_branch] = 'develop'

        flow = described_class.new(valid_json_with_branches)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains state eqls failure' do
        valid_json_with_state_failure = valid_json.deep_dup

        valid_json_with_state_failure[:check_run][:conclusion] = 'failure'

        flow = described_class.new(valid_json_with_state_failure)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains state eqls pending' do
        valid_json_with_state_pending = valid_json.deep_dup

        valid_json_with_state_pending[:check_run][:conclusion] = 'pending'

        flow = described_class.new(valid_json_with_state_pending)

        expect(flow.flow?).to be_truthy
      end

      it 'a check run contains state eqls success' do
        valid_json_with_state_success = valid_json.deep_dup

        valid_json_with_state_success[:check_run][:conclusion] = 'success'

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
        invalid_json[:check_run][:head_sha] = nil

        flow = described_class.new(invalid_json)

        expect(flow.flow?).to be_falsey
      end

      it 'a check run doesnt contains branch name' do
        invalid_json = valid_json.deep_dup
        invalid_json[:check_run][:check_suite][:head_branch] = ''

        flow = described_class.new(invalid_json)

        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    it 'sends a message if the check run is correct' do
      VCR.use_cassette('flows#check-run#check-run-send-message', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        user = FactoryBot.create(:user, slack: 'rheniery.mendes')
        pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'Rheniery-patch-9')
        FactoryBot.create(:commit, sha: '1', pull_request: pull_request)

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send)

        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send)

        flow.run
      end
    end

    it 'sends failure message and reaction if check run state eqls failure' do
      repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
      slack_message = FactoryBot.create(:slack_message, ts: '123')
      user = FactoryBot.create(:user, slack: 'rheniery.mendes')
      pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'Rheniery-patch-9')
      FactoryBot.create(:commit, sha: '1', pull_request: pull_request)
      branch = FactoryBot.create(:branch, name: 'Rheniery-patch-9', repository: repository, pull_request: pull_request)
      FactoryBot.create(:check_run, state: 'failure', branch: branch)

      flow = described_class.new(valid_json)

      expected_message = ':rotating_light: CI failed for pull request: <https://github.com/codelittinc/gh-hooks-repo-test/pull/1|gh-hooks-repo-test#1>'
      expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(expected_message, 'rheniery.mendes')
      expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('rotating_light', 'feed-test-automations', '123')

      flow.run
    end

    it 'does not send a failure dm if check run state eqls failure but the user does not have a slack username' do
      repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
      slack_message = FactoryBot.create(:slack_message, ts: '123')
      user = FactoryBot.create(:user, slack: nil)
      pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'Rheniery-patch-9')
      FactoryBot.create(:commit, sha: '1', pull_request: pull_request)
      branch = FactoryBot.create(:branch, name: 'Rheniery-patch-9', repository: repository, pull_request: pull_request)
      FactoryBot.create(:check_run, state: 'failure', branch: branch)

      flow = described_class.new(valid_json)

      expect_any_instance_of(Clients::Slack::DirectMessage).to_not receive(:send)
      expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('rotating_light', 'feed-test-automations', '123')

      flow.run
    end

    it 'sends success reaction if check run state eqls success' do
      repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
      slack_message = FactoryBot.create(:slack_message, ts: '123')
      user = FactoryBot.create(:user, slack: 'rheniery.mendes')
      pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'Rheniery-patch-9')
      FactoryBot.create(:commit, sha: '1', pull_request: pull_request)
      branch = FactoryBot.create(:branch, name: 'Rheniery-patch-9', repository: repository, pull_request: pull_request)
      FactoryBot.create(:check_run, state: 'success', branch: branch)

      valid_json_with_state_success = valid_json.deep_dup

      valid_json_with_state_success[:check_run][:conclusion] = 'success'

      flow = described_class.new(valid_json_with_state_success)

      expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('white_check_mark', 'feed-test-automations', '123')

      flow.run
    end

    it 'sends pending reaction if check run state is different from success or failure' do
      repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
      slack_message = FactoryBot.create(:slack_message, ts: '123')
      user = FactoryBot.create(:user, slack: 'rheniery.mendes')
      pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'Rheniery-patch-9')
      FactoryBot.create(:commit, sha: '1', pull_request: pull_request)
      branch = FactoryBot.create(:branch, name: 'Rheniery-patch-9', repository: repository, pull_request: pull_request)
      FactoryBot.create(:check_run, state: 'pending', branch: branch)

      valid_json_with_random_state = valid_json.deep_dup

      valid_json_with_random_state[:check_run][:conclusion] = ''

      flow = described_class.new(valid_json_with_random_state)

      expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('hourglass', 'feed-test-automations', '123')

      flow.run
    end

    it 'create a check run data' do
      VCR.use_cassette('flows#check-run#create-check-run-data', record: :new_episodes) do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        slack_message = FactoryBot.create(:slack_message, ts: '123')
        user = FactoryBot.create(:user, slack: 'rheniery.mendes')
        pull_request = FactoryBot.create(:pull_request, source_control_id: 1, repository: repository, slack_message: slack_message, user: user, state: 'open', head: 'Rheniery-patch-9')
        FactoryBot.create(:commit, sha: '1', pull_request: pull_request)

        flow = described_class.new(valid_json)

        expect { flow.run }.to change { CheckRun.count }.by(1)
      end
    end
  end
end

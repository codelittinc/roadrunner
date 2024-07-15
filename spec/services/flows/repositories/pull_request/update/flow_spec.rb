# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Flows::Repositories::PullRequest::Update::Flow, type: :service do
  let(:github_valid_json) { load_flow_fixture('github_update_request.json') }
  let(:azure_valid_json) { load_flow_fixture('azure_updated_pull_request.json') }

  context 'Github JSON' do
    let(:repository) do
      FactoryBot.create(:repository, name: 'roadrunner-repository-test', owner: 'codelittinc')
    end

    let(:pull_request) do
      branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository:)
      FactoryBot.create(:pull_request, repository:, source_control_id: 11, branch:)
    end

    describe '#flow?' do
      context 'returns true when' do
        it 'pull request already exists in the database' do
          pull_request
          flow = described_class.new(github_valid_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'return false when' do
        it 'pull request does not exist' do
          flow = described_class.new(github_valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'pull request exists but the action is not an update one' do
          github_pull_request_new = github_valid_json.deep_dup
          github_pull_request_new[:action] = 'opened'

          flow = described_class.new(github_pull_request_new)
          expect(flow.flow?).to be_falsey
        end
      end
    end

    describe '#execute' do
      context 'when the existing pull request is a draft' do
        it 'updates the pull request draft field and sends a notification if it is ready for review' do
          repository
          pull_request.update(draft: true)
          expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).and_return({
                                                                                                 'notification_id' => '123'
                                                                                               })
          expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send)

          github_pull_request_new = github_valid_json.deep_dup
          github_pull_request_new[:action] = 'ready_for_review'
          github_pull_request_new[:pull_request][:draft] = false

          flow = described_class.new(github_valid_json)
          expect(pull_request.draft).to be_truthy
          flow.run
          pull_request.reload
          expect(pull_request.draft).to be_falsey
        end
      end
    end
  end

  context 'Azure JSON' do
    include_context 'mock backstage azure'
    let(:repository) do
      FactoryBot.create(:repository, name: 'ay-users-api-test', owner: 'Avant')
    end

    let(:pull_request) do
      branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository:)
      FactoryBot.create(:pull_request, repository:, source_control_id: 108, branch:)
    end

    describe '#flow?' do
      context 'returns true when' do
        it 'pull request already exists in the database' do
          pull_request
          azure_update_pull_request_json = azure_valid_json.deep_dup
          azure_update_pull_request_json[:eventType] = 'git.pullrequest.updated'
          flow = described_class.new(azure_update_pull_request_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'return false when' do
        it 'pull request does not exist' do
          flow = described_class.new(azure_valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'pull request exists but the action is not an update one' do
          pull_request
          azure_update_pull_request_json = azure_valid_json.deep_dup
          azure_update_pull_request_json[:eventType] = 'git.pullrequest.created'
          flow = described_class.new(azure_update_pull_request_json)

          expect(flow.flow?).to be_falsey
        end
      end
    end

    describe '#execute' do
      context 'when the existing pull request is a draft' do
        it 'updates the pull request draft field and sends a notification if it is ready for review' do
          repository
          pull_request.update(draft: true)
          expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).and_return({
                                                                                                 'notification_id' => '123'
                                                                                               })
          expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send)

          azure_update_pull_request_json = azure_valid_json.deep_dup
          azure_update_pull_request_json[:eventType] = 'git.pullrequest.updated'
          flow = described_class.new(azure_update_pull_request_json)

          expect(pull_request.draft).to be_truthy
          flow.run
          pull_request.reload
          expect(pull_request.draft).to be_falsey
        end
      end
    end
  end
end

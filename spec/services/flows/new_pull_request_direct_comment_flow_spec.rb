# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Flows::NewPullRequestDirectCommentFlow, type: :service do
  before do
    client = double('client')
    allow(Clients::Backstage::User).to receive(:new).and_return(client)

    allow(client).to receive(:list).with(%w[e44d997c-d727-6bec-a3db-8bc537d4b723]).and_return([])
    allow(client).to receive(:list).with(%w[kaiomagalhaes
                                            victor0402]).and_return([
                                                                      BackstageUser.new({ 'id' => 123, 'email' => 'kaio@codelitt.com',
                                                                                          'user_service_identifiers' => [{ 'service_name' => 'slack', 'identifier' => 'kaiomagalhaes' }] }),
                                                                      BackstageUser.new({ 'id' => 123, 'email' => 'victor@codelitt.com',
                                                                                          'user_service_identifiers' => [{ 'service_name' => 'slack', 'identifier' => 'victorcarvalho' }] })
                                                                    ])
    allow(client).to receive(:list).with(%w[kaiomagalhaes
                                            batman]).and_return([
                                                                  BackstageUser.new({ 'id' => 123, 'email' => 'kaio@codelitt.com',
                                                                                      'user_service_identifiers' => [{ 'service_name' => 'slack', 'identifier' => 'kaiomagalhaes' }] })
                                                                ])
  end

  context 'Github JSON' do
    let(:valid_json) { load_flow_fixture('github_new_pull_request_direct_comment.json') }

    describe '#flow?' do
      context 'returns true' do
        it 'with a valid json' do
          repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
          FactoryBot.create(:pull_request, repository:, source_control_id: 151)

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end

        it 'when the pull request exists' do
          repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
          FactoryBot.create(:pull_request, repository:, source_control_id: 151)

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'returns false when' do
        it "action is not 'created'" do
          flow = described_class.new({
                                       comment: {
                                         body: 'nice comment'
                                       },
                                       action: 'not created'
                                     })
          expect(flow.flow?).to be_falsey
        end

        it 'it does not have a comment param' do
          flow = described_class.new({
                                       action: 'not created'
                                     })
          expect(flow.flow?).to be_falsey
        end

        it 'pull request does not exist' do
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end
      end
    end

    describe '#run' do
      context 'when one user only exists on Backstage and the other on the database' do
        it 'sends two slack messages' do
          repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
          FactoryBot.create(:pull_request, repository:, source_control_id: 151)

          flow = described_class.new(valid_json)

          message_count = 0
          allow_any_instance_of(Clients::Notifications::Channel).to receive(:send) { |_arg| message_count += 1 }

          flow.run
          expect(message_count).to eql(2)
        end
      end

      context 'when one user exists on both Backstage and on the database and the other only on the database' do
        it 'sends two slack messages' do
          repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
          FactoryBot.create(:pull_request, repository:, source_control_id: 151, backstage_user_id: 123)

          flow = described_class.new(valid_json)

          message_count = 0
          allow_any_instance_of(Clients::Notifications::Channel).to receive(:send) { |_arg| message_count += 1 }

          flow.run
          expect(message_count).to eql(2)
        end
      end

      context 'when all the two users mentioned exist in the database' do
        it 'sends two slack messages' do
          repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
          FactoryBot.create(:pull_request, repository:, source_control_id: 151)

          flow = described_class.new(valid_json)

          message_count = 0
          allow_any_instance_of(Clients::Notifications::Channel).to receive(:send) { |_arg| message_count += 1 }

          flow.run
          expect(message_count).to eql(2)
        end
      end
    end
  end

  context 'Azure JSON' do
    let(:valid_json) { load_flow_fixture('azure_pull_request_direct_comment.json') }

    describe '#flow?' do
      context 'returns true' do
        it 'with a valid json' do
          repository = FactoryBot.create(:repository, name: 'ay-pia-web', owner: 'Avant')
          FactoryBot.create(:pull_request, repository:, source_control_id: 608)

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end

        it 'when the pull request exists' do
          repository = FactoryBot.create(:repository, name: 'ay-pia-web', owner: 'Avant')
          FactoryBot.create(:pull_request, repository:, source_control_id: 608)

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'returns false when' do
        it "action is not 'created'" do
          flow = described_class.new({
                                       comment: {
                                         body: 'nice comment'
                                       },
                                       action: 'not created'
                                     })
          expect(flow.flow?).to be_falsey
        end

        it 'it does not have a comment param' do
          flow = described_class.new({
                                       action: 'not created'
                                     })
          expect(flow.flow?).to be_falsey
        end

        it 'pull request does not exist' do
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end
      end
    end
  end
end

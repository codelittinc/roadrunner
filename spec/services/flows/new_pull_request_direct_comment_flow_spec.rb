require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::NewPullRequestDirectCommentFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_new_pull_request_direct_comment.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true' do
      it 'with a valid json' do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        FactoryBot.create(:pull_request, repository: repository, github_id: 151)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end

      it 'when the pull request exists' do
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        FactoryBot.create(:pull_request, repository: repository, github_id: 151)

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
    context 'when all the two users mentioned exist in the database' do
      it 'sends two slack messages' do
        FactoryBot.create(:user, github: 'kaiomagalhaes')
        FactoryBot.create(:user, github: 'victor0402')
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        FactoryBot.create(:pull_request, repository: repository, github_id: 151)

        flow = described_class.new(valid_json)

        message_count = 0
        allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

        flow.run
        expect(message_count).to eql(2)
      end
    end

    context 'when only one out of the two users mentioned exist in the database' do
      it 'sends one slack message' do
        FactoryBot.create(:user, github: 'kaiomagalhaes', slack: 'batman')
        repository = FactoryBot.create(:repository, name: 'gh-hooks-repo-test')
        FactoryBot.create(:pull_request, repository: repository, github_id: 151)

        flow = described_class.new(valid_json)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          'Hey @batman, there is a new message for you!',
          'feed-test-automations',
          '123'
        )

        flow.run
      end
    end
  end
end

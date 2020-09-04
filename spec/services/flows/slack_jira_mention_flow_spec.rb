# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::SlackJiraMentionFlow, type: :service do
  let(:jira_mention) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'jira_mention.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true' do
      it 'with a valid json' do
        flow = described_class.new(jira_mention)
        expect(flow.flow?).to be_truthy
      end
    end
  end

  describe '#run' do
    it 'sends a message when there is one mention' do
      user = FactoryBot.create(:user, jira: '5da6024d1a43fe0ddbb45cf5', slack: 'arath')

      flow = described_class.new(jira_mention)

      expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
        'Hey there is a new mention for you on Jira https://codelitt.atlassian.net/browse/HUB-893',
        user.slack
      )

      flow.run
    end
  end
end

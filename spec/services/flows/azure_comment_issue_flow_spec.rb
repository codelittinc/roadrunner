# frozen_string_literal: true

require 'rails_helper'
require 'flows_helper'

RSpec.describe Flows::AzureCommentIssueFlow, type: :service do
  let(:valid_json) { load_flow_fixture('azure_comment_issue.json') }

  describe '#flow?' do
    context 'returns true' do
      it 'with a valid json' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end
  end

  describe '#run' do
    it 'sends a message when there is one mention' do
      # application = FactoryBot.create(:application, :with_server, external_identifier: source)

      flow = described_class.new(valid_json)
      FactoryBot.create(:user, azure_devops_issues: '4d13cd81-e536-6e63-93fa-0de9cffbb868', slack: 'batman')
      message = "You've been mentioned in the Azure Devops Issue #<2988|https://dev.azure.com/AY-InnovationCenter/e57bfb9f-c5eb-4f96-9f83-8a98a76bfda4/_workitems/edit/2988>"

      expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
        message,
        'batman'
      )

      flow.run
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::JiraIssuesReportFlow, type: :service do
  describe '#flow?' do
    context 'returns true when' do
      it 'text is reports jira' do
        flow = described_class.new({
                                     text: 'reports jira'
                                   })

        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'text is different from reports jira' do
        flow = described_class.new({
                                     text: 'not reports jira'
                                   })

        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    it 'sends a message with the reports to the user' do
        flow = described_class.new({
                                     text: 'reports jira'
                                   })

        flow.execute
    end
  end
end

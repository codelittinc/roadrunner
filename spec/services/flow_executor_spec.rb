# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlowExecutor, type: :service do
  describe '#execute' do
    context 'when the is a result' do
      it 'executes the flow' do
        flow_request_text = 'help'
        flow_request = FlowRequest.create!(json: {
          text: flow_request_text,
          user_name: 'rheniery.mendes'
        }.to_json)

        flow_executor = described_class.new(flow_request)

        expect_any_instance_of(Flows::HelpSummaryFlow).to receive(:execute)

        flow_executor.execute!
      end
    end

    context 'when there are no results' do
      it 'sends a direct no results message' do
        flow_request_text = 'test'
        flow_request = FlowRequest.create!(json: {
          text: flow_request_text,
          user_name: 'rheniery.mendes'
        }.to_json)
        flow_executor = described_class.new(flow_request)

        expected_message = "There are no results for *#{flow_request_text}*. Please, check for more information using the `/roadrunner help` command."
        expect_any_instance_of(Clients::Notifications::Direct).to receive(:send).with(expected_message,
                                                                                      'rheniery.mendes')

        flow_executor.execute!
      end
    end
  end
end

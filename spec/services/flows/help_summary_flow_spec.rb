# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::HelpSummaryFlow, type: :service do
  describe '#flow?' do
    context 'returns true' do
      it 'with a valid json' do
        flow = described_class.new({
                                     text: 'help',
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'with an invalid json' do
        flow = described_class.new({
                                     text: 'not help',
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    context 'in a non deploy channel' do
      it 'calls the ApplicationIncidentService with the right params' do
        flow = described_class.new({
                                     text: 'help',
                                     channel_name: 'cool-channel',
                                     user_name: 'kaiomagalhaes'
                                   })

        expect_any_instance_of(Clients::Slack::Direct).to receive(:send).with(
          'Please check our documentation here https://bit.ly/33oZSkt', 'kaiomagalhaes'
        )

        flow.run
      end
    end
  end
end

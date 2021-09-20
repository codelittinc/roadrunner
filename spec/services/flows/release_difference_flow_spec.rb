# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::ReleaseDifferenceFlow, type: :service do
  describe '#can_execute?' do
    context 'returns true' do
      it 'with a valid json' do
        flow = described_class.new({
                                     text: 'release diff BaseRelease HeadRelease',
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_truthy
      end
    end

    context 'returns false' do
      it 'with an invalid json' do
        flow = described_class.new({
                                     text: 'not release diff',
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end
    end
  end
end

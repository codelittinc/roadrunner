# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::Meetings::Flow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'zoom_recording.json'))).with_indifferent_access
  end

  xdescribe '#flow?' do
    context 'returns true' do
      it 'when mp4 meeting_id is present' do
        flow = described_class.new(valid_json)

        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when mp4 meeting_id is absent' do
        flow = described_class.new({})
        expect(flow.flow?).to be_falsey
      end
    end
  end
  describe '#run' do
    it 'sends a post request to the file upload link for zoom' do
      flow = described_class.new(valid_json)
      flow.run
    end
  end
end

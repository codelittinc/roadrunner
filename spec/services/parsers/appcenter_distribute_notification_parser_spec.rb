# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parsers::AppcenterDistributeNotificationParser, type: :service do
  let(:distribute_response) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows',
                                   'appcenter_distribute_notification.json'))).with_indifferent_access
  end

  describe 'returns true when' do
    it 'has version and build numbers' do
      parser = described_class.new(distribute_response)

      expect(parser.can_parse?).to be_truthy
    end
  end

  it 'reads the platform' do
    parser = described_class.new(distribute_response)
    parser.parse!

    expect(parser.platform).to eq('Android')
  end

  it 'reads the version' do
    parser = described_class.new(distribute_response)
    parser.parse!

    expect(parser.version).to eq('1.0.42')
  end

  it 'reads build' do
    parser = described_class.new(distribute_response)
    parser.parse!

    expect(parser.build).to eq('350')
  end
end

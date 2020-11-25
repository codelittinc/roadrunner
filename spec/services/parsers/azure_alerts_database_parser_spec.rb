# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parsers::AzureAlertsDatabaseParser, type: :service do
  let(:alert) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'azure_alerts_database.json'))).with_indifferent_access
  end

  describe 'returns true when' do
    it 'schemaId is AzureMonitorMetricAlert' do
      parser = described_class.new(alert)

      expect(parser.can_parse?).to be_truthy
    end
  end

  it 'reads the schema_id' do
    parser = described_class.new(alert)
    parser.parse!

    expect(parser.schema_id).to eq('AzureMonitorMetricAlert')
  end

  it 'reads threshold' do
    parser = described_class.new(alert)
    parser.parse!

    expect(parser.threshold).to eq('10')
  end
end

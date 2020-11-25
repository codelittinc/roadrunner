# frozen_string_literal: true

require 'ostruct'
module Parsers
  class AzureAlertsDatabaseParser < BaseParser
    attr_reader :schema_id, :threshold

    def can_parse?
      @json && @json[:schemaId] == 'AzureMonitorMetricAlert'
    end

    def parse!
      @schema_id = @json[:schemaId]
      @threshold = @json[:data][:context][:condition][:allOf].first[:threshold]
    end
  end
end

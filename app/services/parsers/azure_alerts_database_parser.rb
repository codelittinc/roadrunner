# frozen_string_literal: true

require 'ostruct'
module Parsers
  class AzureAlertsDatabaseParser < BaseParser
    attr_reader :schema_id, :threshold, :azure_link

    def can_parse?
      @json && @json[:schemaId] == 'AzureMonitorMetricAlert'
    end

    def parse!
      context = @json[:data][:context]
      @schema_id = @json[:schemaId]
      @threshold = context[:condition][:allOf].first[:threshold]
      @azure_link = context[:portalLink]
    end
  end
end

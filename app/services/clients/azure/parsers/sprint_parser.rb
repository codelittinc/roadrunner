# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class SprintParser
        attr_reader :id, :start_date, :end_date, :name

        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!
          @name = @json[:name]
          @id = @json[:id]
          @start_date = @json.dig(:attributes, :start_date)
          @end_date = @json.dig(:attributes, :end_date)
        end
      end
    end
  end
end

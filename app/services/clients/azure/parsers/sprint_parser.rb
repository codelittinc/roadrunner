# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class SprintParser
        attr_reader :id, :start_date, :end_date, :name, :time_frame

        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!
          @id = @json[:id]
          @name = @json[:name]
          @start_date = @json.dig(:attributes, :startDate)
          @end_date = @json.dig(:attributes, :finishDate)
          @time_frame = @json.dig(:attributes, :timeFrame)
          @json = nil
        end
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class RepositoryParser
        attr_reader :name

        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!
          @name = @json[:name]
        end
      end
    end
  end
end

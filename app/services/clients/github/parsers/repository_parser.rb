# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class RepositoryParser
        attr_reader :name

        def initialize(json)
          @json = json
          parse!
        end

        def parse!
          @name = @json[:name]
        end
      end
    end
  end
end

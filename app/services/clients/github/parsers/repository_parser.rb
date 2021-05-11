# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class RepositoryParser
        def initialize(json)
          @json = json
          parse!
        end

        def parse!; end
      end
    end
  end
end

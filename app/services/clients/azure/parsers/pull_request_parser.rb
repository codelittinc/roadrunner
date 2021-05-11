# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class PullRequestParser
        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!; end
      end
    end
  end
end

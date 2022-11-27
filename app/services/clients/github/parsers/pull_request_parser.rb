# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class PullRequestParser < ClientParser
        attr_reader :mergeable, :mergeable_state

        def parse!
          @mergeable = @json[:mergeable]
          @mergeable_state = @json[:mergeable_state]
        end
      end
    end
  end
end

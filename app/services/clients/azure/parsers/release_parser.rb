# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class ReleaseParser
        attr_reader :tag_name

        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!
          @tag_name = @json[:tag_name]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class ReleaseParser
        attr_reader :tag_name, :url

        def initialize(json)
          @json = json
          parse!
        end

        def parse!
          @tag_name = @json[:tag_name]
          @url = @json[:url]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class ReleaseParser < ClientParser
        attr_reader :tag_name, :url

        def parse!
          @tag_name = @json[:tag_name]
          @url = @json[:url]
        end
      end
    end
  end
end

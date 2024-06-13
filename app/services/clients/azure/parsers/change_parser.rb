# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class ChangeParser < ClientParser
        attr_reader :path

        def parse!
          @path = @json.dig(:item, :path)
        end
      end
    end
  end
end

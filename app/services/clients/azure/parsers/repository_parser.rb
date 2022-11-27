# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class RepositoryParser < ClientParser
        attr_reader :name, :owner

        def parse!
          @name = @json[:name]
          @owner = @json.dig(:project, :name)
        end
      end
    end
  end
end

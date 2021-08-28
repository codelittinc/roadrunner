# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class RepositoryParser
        attr_reader :name, :owner, :archived

        def initialize(json)
          @json = json
          parse!
        end

        def parse!
          @name = @json[:name]
          @owner = @json[:owner][:login]
          @archived = @json[:archived]
        end
      end
    end
  end
end

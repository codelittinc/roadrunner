# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class RepositoryParser < ClientParser
        attr_reader :name, :owner, :archived

        def parse!
          @name = @json[:name]
          @owner = @json[:owner][:login]
          @archived = @json[:archived]
        end
      end
    end
  end
end

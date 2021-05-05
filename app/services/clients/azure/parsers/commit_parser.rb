# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class CommitParser
        attr_reader :sha, :author_name, :author_email, :message

        def initialize(json)
          @json = json
          parse!
        end

        def parse!
          @sha = @json[:commitId]
          @author_name = @json[:author][:name]
          @author_email = @json[:author][:email]
          @message = @json[:comment]
        end
      end
    end
  end
end

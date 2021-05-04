# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class CommitParser
        attr_reader :sha, :author_name, :author_email, :message

        def initialize(json)
          @json = json
          parse!
        end

        def parse!
          @sha = @json[:sha]
          @author_name = @json[:commit][:author][:name]
          @author_email = @json[:commit][:author][:email]
          @message = @json[:commit][:message]
        end
      end
    end
  end
end

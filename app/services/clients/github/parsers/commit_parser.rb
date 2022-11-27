# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class CommitParser < ClientParser
        attr_reader :sha, :author_name, :author_email, :message, :date

        def parse!
          @sha = @json[:sha]
          @author_name = @json[:commit][:author][:name]
          @author_email = @json[:commit][:author][:email]
          @message = @json[:commit][:message]
          @date = @json[:commit][:committer][:date]
        end
      end
    end
  end
end

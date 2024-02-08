# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class CommitParser < ClientParser
        attr_reader :sha, :author_name, :author_email, :message, :date

        def parse!
          @sha = @json[:commitId] || @json.dig(:item, :commitId)
          @author_name = @json.dig(:author, :name)
          @author_email = @json.dig(:author, :email)
          @message = @json[:comment]
          @date = @json.dig(:author, :date)
        end
      end
    end
  end
end

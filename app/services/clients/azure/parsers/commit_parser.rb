# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class CommitParser
        attr_reader :sha, :author_name, :author_email, :message, :date

        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!
          @sha = @json[:commitId] || @json.dig(:item, :commitId)
          @author_name = @json.dig(:author, :name)
          @author_email = @json.dig(:author, :email)
          @message = @json[:comment]
          @date = @json.dig(:committer, :date)
        end
      end
    end
  end
end

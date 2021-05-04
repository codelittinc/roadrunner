# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class CommitParser
        attr_reader :sha, :author_name, :author_email, :message

        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!
          @sha = @json[:commitId]
          @author_name = @json.dig(:author, :name)
          @author_email = @json.dig(:author, :email)
          @message = @json[:comment]
        end
      end
    end
  end
end

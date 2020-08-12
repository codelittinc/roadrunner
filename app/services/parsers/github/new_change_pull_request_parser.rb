module Parsers
  module Github
    class NewChangePullRequestParser
      def initialize(json)
        @json = json
      end

      def parse
        {
          branch_name: pull_request.dig(:head, :ref),
          repository_name: @json.dig(:repository, :name),
          github_id: pull_request[:number]
        }
      end

      def pull_request
        @json[:pull_request]
      end
    end
  end
end

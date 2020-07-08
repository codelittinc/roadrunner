module Parsers
  module Github
    class NewPullRequestParser
      def initialize(json)
        @json = json
      end

      def parse
        {
          head: pull_request[:head][:ref],
          base: pull_request[:base][:ref],
          github_id: pull_request[:number],
          repository_name: @json[:repository][:name],
          title: pull_request[:title],
          draft: pull_request[:draft],
          state: pull_request[:state],
          owner: pull_request[:head][:repo][:owner][:login],
          username: pull_request[:user][:login],
          description: pull_request[:body],
          merged_at: pull_request[:merged_at]
        }
      end

      def pull_request
        @json[:pull_request]
      end
    end
  end
end

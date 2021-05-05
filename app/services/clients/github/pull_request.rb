# frozen_string_literal: true

module Clients
  module Github
    class PullRequest < GithubBase
      def get(repository, source_control_id)
        @client.pull_request(repository, source_control_id)
      end

      def list_commits(repository, source_control_id)
        commits = @client.pull_request_commits(repository, source_control_id)
        commits.map do |commit|
          Clients::Github::Parsers::CommitParser.new(commit)
        end
      end
    end
  end
end

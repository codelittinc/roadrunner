# frozen_string_literal: true

module Clients
  module Github
    class PullRequest < GithubBase
      def get(repository, github_id)
        @client.pull_request(repository, github_id)
      end

      def list_commits(repository, github_id)
        @client.pull_request_commits(repository, github_id)
      end
    end
  end
end

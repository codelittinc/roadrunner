# frozen_string_literal: true

module Clients
  module Github
    class Branch < GithubBase
      def delete(repo, branch)
        @client.delete_branch(repo, branch)
      rescue Octokit::UnprocessableEntity
        false
      end

      def commits(repo, branch)
        @client.list_commits(repo, branch)
      end

      def compare(repo, head, base)
        @client.compare(repo, head, base)[:commits]
      end

      def branch_exists?(repo, branch)
        @client.branch(repo, branch)
      rescue Octokit::NotFound
        false
      end
    end
  end
end

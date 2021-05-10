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
        commits = @client.list_commits(repo, branch)
        commits.map do |commit|
          Clients::Github::Parsers::CommitParser.new(commit)
        end
      end

      def compare(repo, head, base)
        commits = @client.compare(repo, head, base)[:commits]
        commits.map do |commit|
          Clients::Github::Parsers::CommitParser.new(commit)
        end
      end

      def branch_exists?(repo, branch)
        @client.branch(repo, branch)
      rescue Octokit::NotFound
        false
      end
    end
  end
end

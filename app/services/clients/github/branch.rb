# frozen_string_literal: true

module Clients
  module Github
    class Branch < GithubBase
      def delete(repository, branch)
        @client.delete_branch(repository.full_name, branch)
      rescue Octokit::UnprocessableEntity
        false
      end

      def commits(repository, branch)
        commits = @client.list_commits(repository.full_name, branch)
        commits.map do |commit|
          Clients::Github::Parsers::CommitParser.new(commit)
        end
      end

      def compare(repository, head, base)
        commits = @client.compare(repository.full_name, head, base)[:commits]
        commits.map do |commit|
          Clients::Github::Parsers::CommitParser.new(commit)
        end
      end

      def branch_exists?(repository, branch)
        @client.branch(repository.full_name, branch)
      rescue Octokit::NotFound
        false
      end
    end
  end
end

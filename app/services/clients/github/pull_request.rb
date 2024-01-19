# frozen_string_literal: true

module Clients
  module Github
    class PullRequest < GithubBase
      def get(repository, source_control_id)
        pull_request = @client.pull_request(repository.full_name, source_control_id)
        Clients::Github::Parsers::PullRequestParser.new(pull_request)
      end

      def comments(repository, source_control_id)
        comments = @client.pull_request_comments(repository.full_name, source_control_id)
        pull_request = GithubPullRequest.find_by(source_control_id:).pull_request
        comments.map do |comment|
          parser = Clients::Github::Parsers::CodeCommentParser.new(comment, pull_request)
          parser.comment.present? ? parser : nil
        end.compact
      end

      def list_commits(repository, source_control_id)
        commits = @client.pull_request_commits(repository.full_name, source_control_id)
        commits.map do |commit|
          Clients::Github::Parsers::CommitParser.new(commit)
        end
      end
    end
  end
end

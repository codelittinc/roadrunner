# frozen_string_literal: true

module Clients
  module Azure
    class PullRequest < AzureBase
      def get(repository, source_control_id)
        url = "#{azure_url(repository)}git/repositories/#{repository.name}/pullrequests/#{source_control_id}"
        pull_request = Request.get(url, authorization(repository))
        Clients::Azure::Parsers::PullRequestParser.new(pull_request)
      end

      def comments(repository, source_control_id)
        url = "#{azure_url(repository)}git/repositories/#{repository.name}/pullrequests/#{source_control_id}/threads?api-version=7.1-preview.1"
        comments_threads = Request.get(url, authorization(repository))
        comments = comments_threads['value'].pluck('comments').flatten

        pull_request = AzurePullRequest.find_by(source_control_id:).pull_request

        comments.map do |comment|
          parser = Clients::Azure::Parsers::CodeCommentParser.new(comment, pull_request)
          parser.comment.nil? ? nil : parser
        end.compact!
      end

      def list_commits(repository, source_control_id)
        url = "#{azure_url(repository)}git/repositories/#{repository.name}/pullrequests/#{source_control_id}?api-version=6.0&includeCommits=true"
        response = Request.get(url, authorization(repository))
        commits = response['commits']
        commits.map do |commit|
          Clients::Azure::Parsers::CommitParser.new(commit)
        end
      end
    end
  end
end

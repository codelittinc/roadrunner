module Flows
  class ClosePullRequestFlow < BaseFlow
    def execute
      pull_request_data = Parsers::Github::NewPullRequestParser.new(@params).parse
      pull_request = PullRequest.where(github_id: pull_request_data[:github_id]).last

      if pull_request_data[:merged_at]
        pull_request.merge!
      else
        pull_request.cancel!
      end
    end

    def isFlow?
      return unless action == 'closed'

      pull_request_data = Parsers::Github::NewPullRequestParser.new(@params).parse
      pull_requests = PullRequest.where(github_id: pull_request_data[:github_id])

      pull_requests.any?
    end

    private

    def action
      @params[:action]
    end
  end
end

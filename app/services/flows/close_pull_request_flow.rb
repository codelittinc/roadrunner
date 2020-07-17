module Flows
  class ClosePullRequestFlow < BaseFlow
    def execute
      pull_request_data = Parsers::Github::NewPullRequestParser.new(@params).parse
      pull_request = PullRequest.where(github_id: pull_request_data[:github_id]).last
      repository = pull_request.repository

      if pull_request_data[:merged_at]
        pull_request.merge!
      else
        pull_request.cancel!
      end

      close_pull_request_message = Messages::Builder.close_pull_request_message(pull_request)
      channel = repository.slack_repository_info.dev_channel

      message_ts = pull_request.slack_message.ts

      response = Clients::Slack::ChannelMessage.new.update(close_pull_request_message, channel, message_ts)
      slack_message = SlackMessage.new(ts: response['ts'], pull_request: pull_request)
      slack_message.save!

      Clients::Github::Branch.new.delete(repository.full_name, pull_request.head)

      commits = Clients::Github::PullRequest.new.list_commits(repository.full_name, pull_request.github_id)
      commits.each do |commit|
        Commit.create!(
          pull_request: pull_request,
          sha: commit[:sha],
          author_name: commit[:commit][:author][:name],
          author_email: commit[:commit][:author][:email],
          message: commit[:commit][:message]
        )
      end
    end

    # @TODO: check if pull request is already closed
    def flow?
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

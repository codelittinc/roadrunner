# frozen_string_literal: true

module Flows
  class NewPullRequestDirectCommentFlow < BaseFlow
    def execute
      slack_message_ts = pull_request.slack_message.ts
      slack_channel = pull_request.repository.slack_repository_info.dev_channel

      mentions = comment.scan(/@([a-zA-Z0-9]+)/).flatten

      User.where(github: mentions).each do |user|
        message = Messages::Builder.new_direct_message(user)
        Clients::Slack::ChannelMessage.new.send(message, slack_channel, slack_message_ts)
      end
    end

    def can_execute?
      @params[:action] == 'created' && comment && pull_request
    end

    private

    def comment
      @comment ||= @params.dig(:comment, :body)
    end

    def pull_request
      @pull_request ||= PullRequest.where(github_id: parser.github_id, repository: Repository.where(name: parser.repository_name).first).first
    end
  end
end

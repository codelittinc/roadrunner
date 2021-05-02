# frozen_string_literal: true

module Flows
  class NewPullRequestDirectCommentFlow < BaseGithubFlow
    def execute
      slack_message_ts = pull_request.slack_message.ts
      slack_channel = pull_request.repository.slack_repository_info.dev_channel

      mentions = comment.scan(/@([a-zA-Z0-9]+)/).flatten

      User.where(github: mentions).each do |user|
        message = Messages::GenericBuilder.new_direct_message(user)
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
  end
end

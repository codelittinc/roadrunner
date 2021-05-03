# frozen_string_literal: true

module Flows
  class ClosePullRequestFlow < BaseSourceControlFlow
    JIRA_CARD_REGEX = %r{https?://codelitt.atlassian.net/browse/[a-zA-Z0-9-]+}

    def execute
      update_pull_request_state!

      close_pull_request_message = Messages::PullRequestBuilder.close_pull_request_message(pull_request)

      message_ts = pull_request.slack_message.ts

      Clients::Slack::ChannelMessage.new.update(close_pull_request_message, channel, message_ts)

      parser.destroy_branch!(pull_request)

      pull_request_description = parser.description
      pull_request.update(description: pull_request_description)

      if pull_request.merged?
        react_to_merge_pull_request!
        send_close_pull_request_notification!
      else
        react_to_cancel_pull_request!
      end

      CommitsCreator.new(repository, pull_request).create!
    end

    def can_execute?
      action == 'closed' && pull_request&.open?
    end

    private

    def react_to_merge_pull_request!
      Clients::Slack::Reactji.new.send('merge2', channel, pull_request.slack_message.ts)
    end

    def react_to_cancel_pull_request!
      Clients::Slack::Reactji.new.send('x', channel, pull_request.slack_message.ts)
    end

    def send_close_pull_request_notification!
      return unless slack_username

      message = Messages::PullRequestBuilder.close_pull_request_notification(pull_request)
      Clients::Slack::DirectMessage.new.send(message, slack_username)
    end

    def update_pull_request_state!
      if parser.merged_at.present?
        pull_request.merge!
      else
        pull_request.cancel!
      end
    end
  end
end

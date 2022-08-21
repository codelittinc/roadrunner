# frozen_string_literal: true

module Flows
  class ClosePullRequestFlow < BaseSourceControlFlow
    def execute
      update_pull_request_state!

      Clients::Slack::Channel.new(customer).update(close_pull_request_message, channel, message_ts)

      parser.destroy_branch!(pull_request)

      pull_request.update(description: parser.description)

      if pull_request.merged?
        react_to_merge_pull_request!
        send_close_pull_request_notification!
      else
        react_to_cancel_pull_request!
      end

      CommitsCreator.new(repository, pull_request, parser.source_control_pull_request).create!
    end

    def can_execute?
      parser.close_pull_request_flow? && pull_request&.open?
    end

    private

    def react_to_merge_pull_request!
      Clients::Slack::Reactji.new(customer).send('airplane_departure', channel, pull_request.slack_message.ts)
    end

    def react_to_cancel_pull_request!
      Clients::Slack::Reactji.new(customer).send('x', channel, pull_request.slack_message.ts)
    end

    def send_close_pull_request_notification!
      return unless slack_username

      urls_from_description = ChangelogsService.urls_from_description(pull_request.description)
      message = Messages::PullRequestBuilder.close_pull_request_notification(pull_request, urls_from_description)
      Clients::Slack::Direct.new(customer).send(message, slack_username, true)
    end

    def close_pull_request_message
      Messages::PullRequestBuilder.close_pull_request_message(pull_request)
    end

    def message_ts
      pull_request.slack_message.ts
    end

    def update_pull_request_state!
      if parser.merged
        pull_request.merge!
        pull_request.update!(merged_at: DateTime.now)
      else
        pull_request.cancel!
      end
    end
  end
end

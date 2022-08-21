# frozen_string_literal: true

module Flows
  class NewChangePullRequestCodeFlow < BaseSourceControlFlow
    def execute
      PullRequestChange.create!(pull_request:)

      change_pull_request_message = Messages::PullRequestBuilder.change_pull_request_message

      message_ts = pull_request.slack_message.ts

      return unless message_ts

      Clients::Slack::Channel.new(customer).send(change_pull_request_message, channel, message_ts)
    end

    def can_execute?
      return false unless pull_request

      reserved_branch = %w[master development develop qa].include? parser.head

      parser.new_change_pull_request_code_flow? && !reserved_branch && pull_request&.open?
    end

    private

    def pull_request
      @pull_request ||= PullRequest.find_by(repository:, head: parser.head, state: 'open')
    end
  end
end

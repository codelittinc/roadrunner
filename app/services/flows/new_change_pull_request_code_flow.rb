# frozen_string_literal: true

module Flows
  class NewChangePullRequestCodeFlow < BaseFlow
    def execute
      PullRequestChange.create!(pull_request: pull_request)

      change_pull_request_message = Messages::PullRequestBuilder.change_pull_request_message

      message_ts = pull_request.slack_message.ts

      return unless message_ts

      Clients::Slack::ChannelMessage.new.send(change_pull_request_message, channel, message_ts)
    end

    def can_execute?
      return false unless @params[:pull_request]

      reserved_branch = %w[master development develop qa].include? parser.head

      action == 'synchronize' && !reserved_branch && pull_request&.open?
    end

    private

    def action
      @params[:action]
    end

    def pull_request
      @pull_request ||= PullRequest.by_repository_and_source_control_id(repository, parser.source_control_id)
    end

    def repository
      # @TODO: add owner verification
      @repository ||= Repository.find_by(name: parser.repository_name)
    end

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end
  end
end

# frozen_string_literal: true

module Flows
  class NewPullRequestDirectCommentFlow < BaseSourceControlFlow
    def execute
      slack_message_ts = pull_request.slack_message.ts
      slack_channel = pull_request.repository.slack_repository_info.dev_channel

      mentions = parser.direct_comment_body.scan(parser.mention_regex).flatten.map(&:downcase)
      users = mentions.map { |mention| User.search_by_term(mention).first }.compact

      users.each do |user|
        message = Messages::GenericBuilder.new_direct_message(user)
        Clients::Slack::ChannelMessage.new(customer).send(message, slack_channel, slack_message_ts)
      end
    end

    def can_execute?
      parser.direct_comment_body && pull_request
    end
  end
end

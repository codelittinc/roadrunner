# frozen_string_literal: true

module Flows
  class NewPullRequestDirectCommentFlow < BaseSourceControlFlow
    def execute
      slack_message_ts = pull_request.slack_message.ts
      slack_channel = pull_request.repository.slack_repository_info.dev_channel

      users = mentions.map { |mention| User.search_by_term(mention).first }.compact

      backstage_users_without_dups = backstage_users.reject { |backstage_user| users.map(&:slack).include?(backstage_user.slack) }

      [backstage_users_without_dups, users].flatten.each do |user|
        message = Messages::GenericBuilder.new_direct_message(user)
        Clients::Notifications::Channel.new(customer).send(message, slack_channel, slack_message_ts)
      end
    end

    def can_execute?
      parser.review_comment && pull_request && mentions.any?
    end

    private

    def mentions
      parser.review_comment.scan(parser.mention_regex).flatten.map(&:downcase)
    end

    def backstage_users
      Clients::Backstage::User.new.list(mentions)
    end
  end
end

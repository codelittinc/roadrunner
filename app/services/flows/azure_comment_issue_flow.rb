# frozen_string_literal: true

module Flows
  class AzureCommentIssueFlow < BaseFlow
    delegate :threshold, :azure_link, :severity, to: :parser

    def execute
      users.each do |user|
        Clients::Slack::DirectMessage.new(user.customer).send(message, user.slack)
      end
    end

    def can_execute?
      parser.event_type == 'workitem.commented'
    end

    private

    def users
      return @user if @user

      regex = /data-vss-mention="version:\d+.\d+,([\da-z-]+)"/
      matches = regex.match(parser.comment).to_a
      matches = matches.reject { |mention| mention.include?('data-vss-mention') }

      return [] if matches.empty?

      User.where('lower(azure_devops_issues) = ?', matches)
    end

    def customer; end

    def message
      Messages::GenericBuilder.azure_devops_isssues_mention(parser.link, parser.issue_number)
    end
  end
end

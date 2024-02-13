# frozen_string_literal: true

module Flows
  class SlackJiraMentionFlow < BaseFlow
    REGEX = /\[~accountid:([a-z0-9]+)\]/

    def execute
      mentions = comment.scan(REGEX).flatten
      backstage_users = Clients::Backstage::User.new.list(mentions)
      backstage_users.each do |user|
        message = "Hey there is a new mention for you on Jira https://codelitt.atlassian.net/browse/#{issue_key}"

        Clients::Notifications::Direct.new.send(
          message,
          user.slack
        )
      end
    end

    def flow?
      @params[:webhookEvent] == 'comment_created'
    end

    private

    def comment
      @comment ||= @params.dig(:comment, :body)
    end

    def issue_key
      @issue_key ||= @params.dig(:issue, :key)
    end
  end
end

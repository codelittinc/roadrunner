module Flows
  class SlackJiraMentionFlow < BaseFlow
    REGEX = /\[~accountid:([a-z0-9]+)\]/.freeze

    def execute
      mentions = comment.scan(REGEX).flatten
      mentions.each do |mention|
        user = User.find_by(jira: mention)
        message = "Hey there is a new mention for you on Jira https://codelitt.atlassian.net/browse/#{issue_key}"

        Clients::Slack::DirectMessage.new.send(
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

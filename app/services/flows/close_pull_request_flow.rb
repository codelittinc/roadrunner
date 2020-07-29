module Flows
  class ClosePullRequestFlow < BaseFlow
    JIRA_CARD_REGEX = %r{https?://codelitt.atlassian.net/browse/[a-zA-Z1-9-]+}.freeze

    def execute
      update_pull_request_state!

      close_pull_request_message = Messages::Builder.close_pull_request_message(pull_request)

      message_ts = pull_request.slack_message.ts

      Clients::Slack::ChannelMessage.new.update(close_pull_request_message, channel, message_ts)

      Clients::Github::Branch.new.delete(repository.full_name, pull_request.head)
      CommitsCreator.new(repository, pull_request).create!

      pull_request_description = pull_request_data[:description]
      pull_request.update(description: pull_request_description)

      if pull_request.merged?
        react_to_merge_pull_request!
        send_jira_notifications!(pull_request_description)
        send_close_pull_request_notification!
      else
        react_to_cancel_pull_request!
      end
    end

    def flow?
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
      message = Messages::Builder.close_pull_request_notification(pull_request)

      Clients::Slack::DirectMessage.new.send(message, pull_request.user.slack)
    end

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end

    def action
      @params[:action]
    end

    def pull_request_data
      @pull_request_data ||= Parsers::Github::NewPullRequestParser.new(@params).parse
    end

    def pull_request
      @pull_request ||= PullRequest.where(github_id: pull_request_data[:github_id]).last
    end

    def repository
      @repository ||= pull_request.repository
    end

    def update_pull_request_state!
      if pull_request_data[:merged_at].present?
        pull_request.merge!
      else
        pull_request.cancel!
      end
    end

    def send_jira_notifications!(pull_request_description)
      jira_mentions = pull_request_description.scan(JIRA_CARD_REGEX)
      jira_mentions.each do |link|
        jira_code = link.scan(/[a-zA-Z]+-\d+$/).first
        Clients::Slack::DirectMessage.new.send_ephemeral(
          jira_notification_block(jira_code),
          pull_request.user.slack
        )
      end
    end

    def jira_notification_block(jira_code)
      [
        {
          "type": 'section',
          "text": {
            "type": 'mrkdwn',
            "text": ":jira: the card *#{jira_code}* was found on the PR *#{repository.name}*-*#{pull_request.github_id}*, do you like to move it to *Ready for QA*?"
          }
        },
        {
          "type": 'actions',
          "block_id": 'actionblock789',
          "elements": [
            {
              "type": 'button',
              "text": {
                "type": 'plain_text',
                "text": 'Yes, please!'
              },
              "style": 'primary',
              "value": 'yes',
              "action_id": "jira-status-update-#{jira_code}"
            }
          ]
        }
      ]
    end
  end
end

# frozen_string_literal: true

module Flows
  class ClosePullRequestFlow < BaseGithubFlow
    JIRA_CARD_REGEX = %r{https?://codelitt.atlassian.net/browse/[a-zA-Z0-9-]+}

    def execute
      update_pull_request_state!

      close_pull_request_message = Messages::PullRequestBuilder.close_pull_request_message(pull_request)

      message_ts = pull_request.slack_message.ts

      Clients::Slack::ChannelMessage.new.update(close_pull_request_message, channel, message_ts)

      Clients::Github::Branch.new.delete(repository.full_name, pull_request.head)

      pull_request_description = parser.description
      pull_request.update(description: pull_request_description)

      if pull_request.merged?
        react_to_merge_pull_request!
        send_jira_notifications!(pull_request_description)
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
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: ":jira: the card *#{jira_code}* was found on the PR *#{repository.name}*-*#{pull_request.source_control_id}*, do you like to move it to *Ready for QA*?"
          }
        },
        {
          type: 'actions',
          block_id: 'actionblock789',
          elements: [
            {
              type: 'button',
              text: {
                type: 'plain_text',
                text: 'Yes, please!'
              },
              style: 'primary',
              value: 'yes',
              action_id: "jira-status-update-#{jira_code}"
            }
          ]
        }
      ]
    end
  end
end

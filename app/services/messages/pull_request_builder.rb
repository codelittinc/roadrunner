# frozen_string_literal: true

module Messages
  class PullRequestBuilder
    def self.new_pull_request_message(pull_request)
      repository = pull_request.repository
      slack_group = repository.slack_repository_info.dev_group

      link = pull_request.link

      format(Templates::PullRequest::NEW_PULL_REQUEST, slack_group, link, repository.name,
             pull_request.source_control_id)
    end

    def self.close_pull_request_message(pull_request)
      "~#{new_pull_request_message(pull_request)}~"
    end

    def self.close_pull_request_notification(pull_request, issue_mentions)
      repository = pull_request.repository
      link = pull_request.link

      base_message = format(Templates::PullRequest::CLOSE_PULL_REQUEST_NOTIFICATION, link, repository.name,
                            pull_request.source_control_id)

      return base_message if issue_mentions.empty?

      urls_message = 'Please update the status of the cards:'
      links = issue_mentions.map do |issue_mention|
        "<#{issue_mention[:link]}|##{issue_mention[:reference_code]}>"
      end
      "#{base_message}. #{urls_message} #{links.join(',')}."
    end

    def self.change_pull_request_message
      Templates::PullRequest::NEW_CHANGE_PULL_REQUEST_NOTIFICATION
    end

    def self.notify_ci_failure(pull_request)
      repository = pull_request.repository
      link = pull_request.link

      format(Templates::PullRequest::NOTIFY_CI_FAILURE, link, repository.name, pull_request.source_control_id)
    end

    def self.notify_changes_request
      ':warning: changes requested!'
    end

    def self.notify_new_message(mention = '')
      empty_mention = mention.empty?
      begin_message = empty_mention ? ':speech_balloon:' : "Hey #{mention}"
      end_message = empty_mention ? '!' : ' for you!'
      "#{begin_message} There is a new message#{end_message}"
    end

    def self.notify_pr_conflicts(pull_request)
      repository = pull_request.repository
      link = pull_request.link

      format(Templates::PullRequest::PULL_REQUEST_CONFLICTS, link, repository.name, pull_request.source_control_id)
    end
  end
end

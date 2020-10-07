# frozen_string_literal: true

module Messages
  class Builder
    def self.new_pull_request_message(pull_request)
      repository = pull_request.repository
      slack_group = repository.slack_repository_info.dev_group

      link = pull_request.github_link

      format(Templates::PullRequest::NEW_PULL_REQUEST, slack_group, link, repository.name, pull_request.github_id)
    end

    def self.close_pull_request_message(pull_request)
      "~#{new_pull_request_message(pull_request)}~"
    end

    def self.new_direct_message(user)
      "Hey @#{user.slack}, there is a new message for you!"
    end

    def self.list_repositories(channel, repositories)
      message = "You can deploy the following repositories on the channel: *#{channel}*"
      repositories.each do |repository|
        message += "\n - #{repository.name}"
      end
      message
    end

    def self.close_pull_request_notification(pull_request)
      repository = pull_request.repository
      link = pull_request.github_link

      format(Templates::PullRequest::CLOSE_PULL_REQUEST_NOTIFICATION, link, repository.name, pull_request.github_id)
    end

    def self.branch_compare_message(commits, format, repository_name)
      title = "Available in the release of *#{repository_name}*:\n"
      prs = commits.reject(&:nil?).map(&:pull_request).uniq(&:id)
      points = prs.map do |pull_request|
        base = " - #{pull_request.title}"
        jira_links = extract_jira_codes(pull_request.description).map do |jira_code|
          if format == 'slack'
            "<https://codelitt.atlassian.net/browse/#{jira_code}|#{jira_code}>"
          else
            "[#{jira_code}](https://codelitt.atlassian.net/browse/#{jira_code})"
          end
        end.join(' ')
        "#{base} #{jira_links}"
      end.join("\n")
      title + points
    end

    def self.extract_jira_codes(text)
      text.scan(%r{https?://codelitt.atlassian.net/browse/([A-Z]+-\d+)}).flatten
    end

    def self.change_pull_request_message
      Templates::PullRequest::NEW_CHANGE_PULL_REQUEST_NOTIFICATION
    end

    def self.notify_ci_failure(pull_request)
      repository = pull_request.repository
      link = pull_request.github_link

      format(Templates::PullRequest::NOTIFY_CI_FAILURE, link, repository.name, pull_request.github_id)
    end

    def self.notify_changes_request
      ':warning: changes requested!'
    end

    def self.notify_new_message(mention = '')
      begin_message = mention == '' ? ':speech_balloon:' : "Hey #{mention}"
      end_message = mention == '' ? '!' : ' for you!'
      "#{begin_message} There is a new message#{end_message}"
    end

    def self.notify_pr_conflicts(pull_request)
      repository = pull_request.repository
      link = pull_request.github_link

      format(Templates::PullRequest::PULL_REQUEST_CONFLICTS, link, repository.name, pull_request.github_id)
    end

    def self.branch_compare_message_hotfix(commits, format, repository_name)
      title = "Available in the release of *#{repository_name}*:\n"
      points = commits.compact.map do |commit|
        base = " - #{commit.message}"
        if commit.message.match?('https://codelitt.atlassian.net/browse')
          jira_links = extract_jira_codes(commit.message).map do |jira_code|
            if format == 'slack'
              "<https://codelitt.atlassian.net/browse/#{jira_code}|#{jira_code}>"
            else
              "[#{jira_code}](https://codelitt.atlassian.net/browse/#{jira_code})"
            end
          end.join(' ')
          base = "#{base} #{jira_links}"
        end
        base
      end
      title + points.select { |c| c }.join("\n")
    end

    def self.notify_release_action(action, environment, user_name, repository_name)
      "#{action.capitalize} release to *#{repository_name}* *#{environment.upcase}* triggered by @#{user_name}"
    end

    def self.notify_branch_existence(branch_name, exist = false)
      "Hey the branch `#{branch_name}` #{'does not' unless exist} exist"
    end

    def self.notify_no_commits_changes(environment, repository_name)
      "Hey the *#{repository_name}* *#{environment.upcase}* environment already up to date"
    end

    def self.notify_sentry_error(title, metadata, user, browser_name, link_sentry)
      message = "\n *_#{title}_*"
      message += "\n *File Name*: #{metadata[:filename]}" if metadata[:filename] && metadata[:filename] != '<anonymous>'
      message += "\n *Function*: #{metadata[:function]}" if metadata[:function]
      message += "\n *User*: \n>Id - #{user[:id]}\n>Email - #{user[:email]}"
      message += "\n *Browser*: #{browser_name}"
      message += "\n\n *Link*: <#{link_sentry}|See issue in Sentry.io>"
      message
    end
  end
end

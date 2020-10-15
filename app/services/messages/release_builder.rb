# frozen_string_literal: true

module Messages
  class ReleaseBuilder
    def self.branch_compare_message(commits, format, repository_name)
      title = "Available in the release of *#{repository_name}*:\n"
      prs = commits.reject(&:nil?).map(&:pull_request).uniq(&:id)
      points = prs.map do |pull_request|
        base = " - #{pull_request.title}"
        jira_links = Messages::GenericBuilder.extract_jira_codes(pull_request.description).map do |jira_code|
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

    def self.branch_compare_message_hotfix(commits, format, repository_name)
      title = "Available in the release of *#{repository_name}*:\n"
      points = commits.compact.map do |commit|
        base = " - #{commit.message}"
        if commit.message.match?('https://codelitt.atlassian.net/browse')
          jira_links = Messages::GenericBuilder.extract_jira_codes(commit.message).map do |jira_code|
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

    def self.notify_branch_existence(branch_name, exist)
      "Hey the branch `#{branch_name}` #{'does not' unless exist} exist"
    end

    def self.notify_no_commits_changes(environment, repository_name)
      "Hey the *#{repository_name}* *#{environment.upcase}* environment is already up to date"
    end
  end
end

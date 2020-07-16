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

    def self.branch_compare_message(commits, format)
      title = "Available in this release *candidate*:\n"
      prs = commits.map(&:pull_request).uniq(&:id)
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
  end
end

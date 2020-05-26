module Flows
  class JiraSpotcheckFlow < BaseFlow
    def execute
      username = @params[:user_name]

      project_keys = Repository.all.map(&:jira_project).compact
      issues_list = []
      project_keys.map do |key|
        issues = Clients::Jira::Issue.new.list(key, "In Progress")
        unless issues.empty?
          issues_list << issues.shuffle[0]
        end
      end

      urls = issues_list.map do |issue|
        Clients::Jira::Issue.build_url(issue["key"])
      end

      message = "Here is your Jira spotcheck:\n"
      formatted_urls = urls.map do |url|
        " - #{url}\n"
      end.join
      message = "#{message}#{formatted_urls}"

      Clients::Slack::DirectMessage.new.send(
        message,
        username
      )
    end

    def isFlow?
      text = @params[:text]
      return false if text.nil?

      text.downcase.include?('spotcheck')
    end
  end
end
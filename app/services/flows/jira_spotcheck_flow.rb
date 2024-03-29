# frozen_string_literal: true

module Flows
  class JiraSpotcheckFlow < BaseFlow
    def execute
      username = @params[:user_name]

      project_keys = Repository.all.map(&:jira_project).compact

      issues_list = []
      project_keys.map do |key|
        issues = Clients::Jira::Issue.new.list(key, 'In Progress')
        issues_list << issues.sample unless issues.empty?
      end

      issues_list = issues_list.uniq

      urls = issues_list.map do |issue|
        Clients::Jira::JiraBase.new.build_browser_url(issue['key'])
      end

      message = "Here is your Jira spotcheck:\n"
      formatted_urls = urls.map do |url|
        " - #{url}\n"
      end.join
      message = "#{message}#{formatted_urls}"

      Clients::Notifications::Direct.new.send(
        message,
        username
      )
    end

    def flow?
      text = @params[:text]
      return false if text.nil?

      text.downcase.include?('spotcheck')
    end
  end
end

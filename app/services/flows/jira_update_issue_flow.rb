# frozen_string_literal: true

module Flows
  class JiraUpdateIssueFlow < BaseFlow
    def execute
      Clients::Jira::Issue.new.update_status(issue_key, status_name)

      message = "#{issue_key} was moved to *#{status_name.upcase}*"

      Clients::Notifications::Direct.new.send(
        message,
        username
      )
    end

    def flow?
      !issue_key.nil? && !status_name.nil?
    end

    private

    def issue_key
      @params[:issue_key]
    end

    def status_name
      @params[:status_name]
    end

    def username
      @params[:username]
    end
  end
end

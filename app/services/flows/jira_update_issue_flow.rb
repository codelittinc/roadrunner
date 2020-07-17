module Flows
  class JiraUpdateIssueFlow < BaseFlow
    def execute
      update_status = Clients::Jira::Issue.new.update_status(issue_key, status_name)

      message = "#{issue_key} was moved to *#{status_name.upcase}*"

      Clients::Slack::DirectMessage.new.send(
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

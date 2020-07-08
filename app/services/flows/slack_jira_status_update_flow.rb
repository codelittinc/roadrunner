require 'json'

module Flows
  class SlackJiraStatusUpdateFlow < BaseFlow
    def execute
      issue_key = action[:action_id][/[A-Z]+-\d+$/]
      status_name = 'READY FOR QA'
      username = user[:username]

      update_status = Clients::Jira::Issue.new.update_status(issue_key, status_name)

      message = "#{issue_key} was moved to *#{status_name.upcase}*"

      Clients::Slack::DirectMessage.new.send(
        message,
        username
      )
    end

    def isFlow?
      return if @params[:payload].nil?

      actions&.find do |action|
        action[:action_id].include?('jira-status-update') && action[:value] == 'yes'
      end
    end

    private

    def payload
      JSON.parse(@params[:payload]).with_indifferent_access
    end

    def actions
      payload[:actions]
    end

    def action
      actions.first
    end

    def user
      payload[:user]
    end
  end
end

# frozen_string_literal: true

module Messages
  class GenericBuilder
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

    # rubocop:disable Metrics/ParameterLists
    def self.notify_sentry_error(title, metadata, user, browser_name, link_sentry, caught_by_exception_handler, custom_message)
      type_message = if caught_by_exception_handler
                       'Caught Exception'
                     else
                       'Uncaught Exception'
                     end

      message = "\n *_#{title}_*"
      message += "\n *Type*: #{type_message}"
      message += "\n *Displayed message*: #{custom_message}" if custom_message
      message += "\n *File Name*: #{metadata[:filename]}" if metadata[:filename] && metadata[:filename] != '<anonymous>'
      message += "\n *Function*: #{metadata[:function]}" if metadata[:function]
      message += "\n *User*: \n>Id - #{user[:id]}\n>Email - #{user[:email]}"
      message += "\n *Browser*: #{browser_name}"
      message += "\n\n *Link*: <#{link_sentry}|See issue in Sentry.io>"
      message
    end
    # rubocop:enable Metrics/ParameterLists

    def self.notify_no_results_from_flow
      'There are no results for your request. Please, check for more information using the `/roadrunner help` command.'
    end

    def self.notify_exception_from_flow
      'There was an error with your request. Hey @automations-dev can you please check this?'
    end

    def self.extract_jira_codes(text)
      text.scan(%r{https?://codelitt.atlassian.net/browse/([A-Z]+-\d+)}).flatten
    end

    def self.azure_database_notification(server, database_usage, azure_link, severity)
      repository = server.repository

      message = ":bellhop_bell: <#{repository.github_link}|#{repository.name}> environment :bellhop_bell:<#{server.link}|#{server.environment&.upcase}>:bellhop_bell:\n\n\n"
      low_severity = 3

      if severity.to_i <= low_severity
        message += "The database usage of the server is at *#{database_usage}%*!"
      else
        slack_group = server.slack_repository_info.dev_group
        message += ":fire: #{slack_group} the database usage of the server is at *#{database_usage}%*!"
      end
      message + "\n\n\n Click <#{azure_link}|here> to see this application on Azure."
    end
  end
end

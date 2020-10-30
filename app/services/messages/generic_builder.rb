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

    def self.notify_sentry_error(title, metadata, user, browser_name, link_sentry)
      message = "\n *_#{title}_*"
      message += "\n *File Name*: #{metadata[:filename]}" if metadata[:filename] && metadata[:filename] != '<anonymous>'
      message += "\n *Function*: #{metadata[:function]}" if metadata[:function]
      message += "\n *User*: \n>Id - #{user[:id]}\n>Email - #{user[:email]}"
      message += "\n *Browser*: #{browser_name}"
      message += "\n\n *Link*: <#{link_sentry}|See issue in Sentry.io>"
      message
    end

    def self.notify_no_results_from_flow
      'There are no results for your request. Please, check for more information using the `/roadrunner help` command.'
    end

    def self.notify_exception_from_flow
      'There was an error with your request. Hey @automations-dev can you please check this?'
    end

    def self.extract_jira_codes(text)
      text.scan(%r{https?://codelitt.atlassian.net/browse/([A-Z]+-\d+)}).flatten
    end
  end
end
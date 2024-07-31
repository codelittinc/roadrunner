# frozen_string_literal: true

module Flows
  class HelpSummaryFlow < BaseFlow
    def execute
      docs_link = 'https://bit.ly/33oZSkt'
      message = "Please check our documentation here #{docs_link}"

      Clients::Notifications::Direct.new.send(message, parser.user_name)
    end

    def can_execute?
      parser.text == 'help'
    end
  end
end

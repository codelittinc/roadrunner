module Flows
  class GraylogsErrorNotificationFlow < BaseFlow
    def execute
      fields = @params[:event][:fields]
      message = fields[:Message]
      source = fields[:Source]

      slack_message = ":fire: on *#{source}* message: \n\n```#{message}```"
      Clients::Slack::DirectMessage.new.send(
        slack_message,
        'kaiomagalhaes'
      )
    end

    def isFlow?
      text = @params[:event_definition_title]
      return true unless text.nil?
    end
  end
end
module Flows
  class GraylogsErrorNotificationFlow < BaseFlow
    def execute
      fields = @params[:event][:fields]
      message = fields[:Message]
      source = fields[:Source]

      server = Server.where(link: source).first
      if server
        slack_channel = server.slack_repository_info.deploy_channel
        slack_group = server.slack_repository_info.dev_group

        slack_message = ":fire: #{slack_group} :fire: on *#{source}* message: \n\n```#{message}```"
        Clients::Slack::ChannelMessage.new.send(
          slack_message,
          slack_channel
        )
      else
        slack_message = ":fire: on *#{source}* message: \n\n```#{message}```"
        Clients::Slack::DirectMessage.new.send(
          slack_message,
          'kaiomagalhaes'
        )
      end
    end

    def isFlow?
      text = @params[:event_definition_title]
      return true unless text.nil?
    end
  end
end
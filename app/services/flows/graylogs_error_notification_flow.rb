module Flows
  class GraylogsErrorNotificationFlow < BaseFlow
    def execute
      fields = @params[:event][:fields]
      incident_message = fields[:Message]
      source = fields[:Source]

      server = Server.where("link LIKE ?", "%#{source}%").first

      if server
        ServerIncidentService.new.register_incident!(server, incident_message)
      else
        slack_message = ":fire: on *#{source}* incident_message: \n\n```#{incident_message}```"
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
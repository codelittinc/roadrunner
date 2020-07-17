module Flows
  class GraylogsErrorNotificationFlow < BaseFlow
    def execute
      fields = @params[:event][:fields]
      incident_message = fields[:Message]
      source = fields[:Source]

      server = Server.where('link LIKE ?', "%#{source}%").first

      ServerIncidentService.new.register_incident!(server, incident_message) if server
    end

    def flow?
      text = @params[:event_definition_title]
      return true unless text.nil?
    end
  end
end

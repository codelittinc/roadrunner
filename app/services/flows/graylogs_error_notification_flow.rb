# frozen_string_literal: true

module Flows
  class GraylogsErrorNotificationFlow < BaseFlow
    def execute
      incident_message = fields[:Message]

      ServerIncidentService.new.register_incident!(server, incident_message)
    end

    def flow?
      text = @params[:event_definition_title]
      text && server
    end

    private

    def server
      @server ||= Server.where('link LIKE ?', "%#{source}%").first
    end

    def source
      fields[:Source]
    end

    def fields
      @params[:event][:fields]
    end
  end
end

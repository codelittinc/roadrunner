# frozen_string_literal: true

module Flows
  class GraylogsIncidentNotificationFlow < BaseFlow
    def execute
      ServerIncidentService.new.register_incident!(server, incident_message)
    end

    def flow?
      text = @params[:event_definition_title]
      text && server
    end

    private

    def server
      @server ||= application&.server
    end

    def application
      @application ||= Application.find_by(external_identifier: source)
    end

    def source
      fields[:Source]
    end

    def fields
      @params[:event][:fields]
    end

    def incident_message
      @incident_message ||= fields[:Message] || 'No error message was provided.'
    end
  end
end

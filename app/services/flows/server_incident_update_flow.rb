# frozen_string_literal: true

module Flows
  class ServerIncidentUpdateFlow < BaseFlow
    def execute
      if white_check_mark_reaction?
        server_incident.in_progress!
      elsif heavy_check_mark_reaction?
        server_incident.complete!
      end
    end

    def flow?
      return false unless @params[:action] == 'added-incident-update-reaction'
      return false unless slack_message
      return false unless server_incident
      return false unless reaction

      white_check_mark_reaction? || heavy_check_mark_reaction?
    end

    private

    def base_message
      slack_message&.text
    end

    def slack_message
      @slack_message ||= SlackMessage.find_by(ts: timestamp)
    end

    def timestamp
      @params[:ts]
    end

    def project_name
      @project_name ||= base_message[ServerIncident::REGEX_PROJECT_IN_INCIDENT_MESSAGE]
    end

    def server
      @server ||= Server.find_by(external_identifier: project_name)
    end

    def channel
      @params[:channel]
    end

    def reaction
      @reaction ||= @params[:reaction]
    end

    def white_check_mark_reaction?
      reaction.include?('white_check_mark')
    end

    def heavy_check_mark_reaction?
      reaction.include?('heavy_check_mark')
    end

    def server_incident
      return @server_incident if @server_incident

      @server_incident = ServerIncident.where(server: server, slack_message_id: slack_message).open_incidents.last
    end
  end
end

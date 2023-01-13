# frozen_string_literal: true

module Flows
  module Notifications
    module Incident
      module GraylogsRegister
        class Flow < BaseFlow
          delegate :application, :source, :fields, :incident_message, :event_definition_title, to: :parser

          def execute
            ApplicationIncidentService.new.register_incident!(application, incident_message)
          end

          def can_execute?
            source = @params.dig(:event, :fields, :Source)
            return false unless source

            application = Application.by_external_identifier(source)
            @params[:event_definition_title] && application
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Flows
  module Notifications
    module Incident
      module AzureMonitor
        class Flow < BaseFlow
          delegate :event_message, :application, to: :parser

          def execute
            ApplicationIncidentService.new.register_incident!(
              application,
              event_message,
              nil,
              ApplicationIncidentService::GRAYLOG_MESSAGE_TYPE
            )
          end

          def can_execute?
            @params[:schemaId] == 'azureMonitorCommonAlertSchema'
          end
        end
      end
    end
  end
end

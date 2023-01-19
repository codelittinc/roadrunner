# frozen_string_literal: true

module Flows
  module Notifications
    module Incident
      module DatadogRegister
        class Flow < BaseFlow
          delegate :event_message, :application, to: :parser

          def execute
            ApplicationIncidentService.new.register_incident!(application, event_message, nil, ApplicationIncidentService::DATADOG_MESSAGE_TYPE)
          end

          def can_execute?
            is_error_or_warn = @params[:event_type] == 'error_tracking_alert' || @params[:event_type] == 'warn_tracking_alert'
            is_from_datadog = @params[:origin] == 'datadog'
            is_from_datadog && is_error_or_warn && application
          end
        end
      end
    end
  end
end

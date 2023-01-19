# frozen_string_literal: true

module Flows
  module Notifications
    module Incident
      module DatadogRegister
        class Parser < Parsers::BaseParser
          attr_reader :event_message, :event_type, :origin

          def can_parse?
            is_error_or_warn = @json[:event_type] == 'error_tracking_alert' || @json[:event_type] == 'warn_tracking_alert'
            is_from_datadog = @json[:origin] == 'datadog'
            is_from_datadog && is_error_or_warn && application
          end

          def parse!
            @event_message = @json[:event_message]
            @event_type = @json[:event_type]
            @origin = @json[:origin]
          end

          def application
            datadog_identifier = "datadog::#{project_name}"
            # the new datadog format should exist in the external_identifier table
            # example: datadog::roadrunner
            @application = Application.by_external_identifier(datadog_identifier)
          end

          private

          def project_name
            message = @json[:event_message]
            # should grab the project name from the datadog error message.
            # example: [[key::project::roadrunner]]
            message[/#{Regexp.escape('[[key::project::')}(.*?)#{Regexp.escape(']]')}/m, 1]
          end
        end
      end
    end
  end
end

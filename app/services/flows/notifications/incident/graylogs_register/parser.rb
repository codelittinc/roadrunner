# frozen_string_literal: true

module Flows
  module Notifications
    module Incident
      module GraylogsRegister
        class Parser < Parsers::BaseParser
          attr_reader :source, :fields, :incident_message, :event_definition_title

          def can_parse?
            @json[:event_definition_title] && application
          end

          def parse!
            @fields = @json.dig(:event, :fields)
            @source = fields[:Source]
            @incident_message = fields[:Message] || 'No error message was provided.'
            @event_definition_title = @json[:event_definition_title]
          end

          def application
            return @application unless @application.nil?

            source = @json.dig(:event, :fields, :Source)
            return nil unless source

            @application ||= Application.by_external_identifier(source)
          end
        end
      end
    end
  end
end

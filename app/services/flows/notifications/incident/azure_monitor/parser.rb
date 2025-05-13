# frozen_string_literal: true

module Flows
  module Notifications
    module Incident
      module AzureMonitor
        class Parser < Parsers::BaseParser
          attr_reader :event_message, :event_type, :origin

          def can_parse?
            @json[:schemaId] == 'azureMonitorCommonAlertSchema' &&
              application
          end

          def parse!
            condition = @json.dig(:data, :alertContext, :condition, :allOf)&.first
            return unless condition

            dimensions = condition[:dimensions]&.to_h { |d| [d[:name], d[:value]] }
            return unless dimensions

            @event_message = format_error_message(dimensions)
            @event_type = 'error_tracking_alert'
            @origin = 'azure_monitor'
          end

          def application
            target_id = @json.dig(:data, :essentials, :alertTargetIDs)&.first
            return nil unless target_id

            app_name = target_id.split('/').last
            @application = Application.by_external_identifier(app_name)
          end

          private

          def investigation_link
            @json.dig(:data, :essentials, :investigationLink)
          end

          def format_error_message(dimensions)
            if dimensions['statusCode'].present? && dimensions['statusCode'] != '<EMPTY_VALUE>'
              format_http_error(dimensions)
            elsif dimensions['type'].present? && dimensions['problemId'].present?
              format_server_exception(dimensions)
            else
              # Fallback for unknown alert types
              "Unknown Alert Type\nRaw Dimensions: #{dimensions.inspect}"
            end
          end

          def format_http_error(dimensions)
            method = dimensions['method']
            url = dimensions['url']
            status_code = dimensions['statusCode']
            user = begin
              JSON.parse(dimensions['user'])
            rescue StandardError
              {}
            end
            user_name = user['name']

            "An HTTP #{status_code} error occurred in the application.\n\n" \
              "Request Details:\n" \
              "• Method: #{method}\n" \
              "• URL: #{url}\n" \
              "• User: #{user_name}\n\n" \
              "For more details, visit the Azure investigation link:\n" \
              "#{investigation_link}"
          end

          def format_server_exception(dimensions)
            type = dimensions['type']
            problem_id = dimensions['problemId']
            outer_message = dimensions['outerMessage']
            method = dimensions['method']
            url = dimensions['url']
            user = begin
              JSON.parse(dimensions['user'])
            rescue StandardError
              {}
            end
            user_name = user['name']

            "A server exception occurred in the application.\n\n" \
              "Exception Details:\n" \
              "• Type: #{type}\n" \
              "• Location: #{problem_id}\n" \
              "• Message: #{outer_message}\n\n" \
              "Request Details:\n" \
              "• Method: #{method}\n" \
              "• URL: #{url}\n" \
              "• User: #{user_name}\n\n" \
              "For more details, visit the Azure investigation link:\n" \
              "#{investigation_link}"
          end
        end
      end
    end
  end
end

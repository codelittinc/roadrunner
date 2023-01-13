# frozen_string_literal: true

module Flows
  module Notifications
    module Incident
      module GraylogsUpdater
        class Parser < Parsers::BaseParser
          attr_reader :action, :base_message, :full_message, :slack_message, :timestamp, :username, :channel

          def can_parse?
            @slack_message ||= SlackMessage.select(:text).find_by(ts: @json[:ts])
            @json[:action] == 'user-addressing-error' && slack_message&.text
          end

          def parse!
            @action = @json[:action]
            @timestamp = @json[:ts]
            @username = @json[:username]
            @channel = @json[:channel]
            @slack_message ||= SlackMessage.select(:text).find_by(ts: timestamp)
            @base_message = slack_message&.text
            @full_message = build_full_message
          end

          private

          def build_full_message
            base_text = base_message.scan(/(^.*)\n?/).first.first.strip
                                    .gsub(':fire:', ':fire_engine:')
                                    .gsub(':droplet:', ':fire_engine:')
            "#{base_text} - reviewed by @#{username}"
          end
        end
      end
    end
  end
end

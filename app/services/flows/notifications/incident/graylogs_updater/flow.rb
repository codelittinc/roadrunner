# frozen_string_literal: true

module Flows
  module Notifications
    module Incident
      module GraylogsUpdater
        class Flow < BaseFlow
          delegate :full_message, :timestamp, :channel, to: :parser

          def execute
            Clients::Notifications::Channel.new.update(full_message, channel, timestamp)
          end

          def can_execute?
            slack_message = SlackMessage.select(:text).find_by(ts: @params[:ts])
            @params[:action] == 'user-addressing-error' && slack_message&.text
          end
        end
      end
    end
  end
end

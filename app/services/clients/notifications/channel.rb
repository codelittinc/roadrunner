# frozen_string_literal: true

module Clients
  module Notifications
    class Channel < Client
      def send(message, channel, timestamp = nil, uniq = false)
        request('/channel_messages', {
                  message:,
                  channel:,
                  notification_id: timestamp,
                  uniq:
                })
      end

      def update(message, channel, timestamp)
        request("/channel_messages/#{timestamp}", {
                  message:,
                  channel:,
                  notification_id: timestamp
                })
      end
    end
  end
end

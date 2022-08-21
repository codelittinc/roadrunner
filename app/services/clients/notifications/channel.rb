# frozen_string_literal: true

module Clients
  module Notifications
    class Channel < Client
      def send(message, channel, notification_id = nil, uniq = false)
        request('/channel_messages', {
                  message:,
                  channel:,
                  notification_id:,
                  uniq:
                })
      end

      def update(message, channel, notification_id)
        request("/channel_messages/#{timestamp}", {
                  message:,
                  channel:,
                  notification_id:
                })
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module Notifications
    class Reactji < Client
      def send(reaction, channel, timestamp)
        request('/reactions', {
                  reaction:,
                  channel:,
                  notification_id: timestamp
                })
      end
    end
  end
end

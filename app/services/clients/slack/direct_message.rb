# frozen_string_literal: true

module Clients
  module Slack
    class DirectMessage < Client
      def send(message, username, uniq = false)
        return if !username || username.size < 3

        request('/direct_messages', {
                  message:,
                  username:,
                  uniq:
                })
      end
    end
  end
end

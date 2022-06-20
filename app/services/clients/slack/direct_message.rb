# frozen_string_literal: true

module Clients
  module Slack
    class DirectMessage < BaseSlack
      def send(message, username, uniq = false)
        url = build_url('/direct_messages')
        return if !username || username.size < 3

        Request.post(url, authorization, build_params({
                                                        message:,
                                                        username:,
                                                        uniq:
                                                      }))
      end
    end
  end
end

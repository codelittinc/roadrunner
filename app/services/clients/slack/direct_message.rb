# frozen_string_literal: true

module Clients
  module Slack
    class DirectMessage < BaseSlack
      def send(message, username, uniq = false)
        url = build_url('/direct_messages')
        Request.post(url, authorization, build_params({
                                                        message: message,
                                                        username: username,
                                                        uniq: uniq
                                                      }))
      end
    end
  end
end

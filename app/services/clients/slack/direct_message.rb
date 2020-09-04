# frozen_string_literal: true

module Clients
  module Slack
    class DirectMessage < BaseSlack
      def send(message, username)
        url = build_url('/direct-messages')
        Request.post(url, authorization, build_params({
                                                        message: message,
                                                        username: username
                                                      }))
      end

      def send_ephemeral(blocks, username)
        url = build_url('/direct-ephemeral-messages')
        Request.post(url, authorization, build_params({
                                                        blocks: blocks,
                                                        username: username
                                                      }))
      end
    end
  end
end

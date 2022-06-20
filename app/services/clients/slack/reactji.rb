# frozen_string_literal: true

module Clients
  module Slack
    class Reactji < BaseSlack
      def send(reaction, channel, timestamp)
        url = build_url('/reactions')
        Request.post(url, authorization, build_params({
                                                        reaction:,
                                                        channel:,
                                                        notification_id: timestamp
                                                      }))
      end
    end
  end
end

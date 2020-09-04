# frozen_string_literal: true

module Clients
  module Slack
    class ChannelMessage < BaseSlack
      def send(message, channel, timestamp = nil)
        url = build_url('/channel-messages')
        response = Request.post(url, authorization, build_params({
                                                                   message: message,
                                                                   channel: channel,
                                                                   ts: timestamp
                                                                 }))
        JSON.parse(response.body)
      end

      def update(message, channel, timestamp)
        url = build_url('/channel-messages')
        response = Request.patch(url, authorization, build_params({
                                                                    message: message,
                                                                    channel: channel,
                                                                    ts: timestamp
                                                                  }))
        JSON.parse(response.body)
      end
    end
  end
end

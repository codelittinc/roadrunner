# frozen_string_literal: true

module Clients
  module Slack
    class ChannelMessage < BaseSlack
      def send(message, channel, timestamp = nil, uniq = false)
        url = build_url('/channel_messages')
        response = Request.post(url, authorization, build_params({
                                                                   message:,
                                                                   channel:,
                                                                   notification_id: timestamp,
                                                                   uniq:
                                                                 }))
        JSON.parse(response.body)
      end

      def update(message, channel, timestamp)
        url = build_url("/channel_messages/#{timestamp}")
        response = Request.patch(url, authorization, build_params({
                                                                    message:,
                                                                    channel:,
                                                                    notification_id: timestamp
                                                                  }))
        JSON.parse(response.body)
      end
    end
  end
end

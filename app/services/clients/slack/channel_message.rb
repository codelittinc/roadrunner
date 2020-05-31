module Clients
  module Slack
    class ChannelMessage < BaseSlack
      def send message, channel
        url = build_url('/channel-messages')
        Request.post(url, authorization, build_params({
          message: message,
          channel: channel
        }))
      end
    end
  end
end
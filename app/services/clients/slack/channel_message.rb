module Clients
  module Slack
    class ChannelMessage < BaseSlack
      def send(message, channel)
        url = build_url('/channel-messages')
        response = Request.post(url, authorization, build_params({
                                                                   message: message,
                                                                   channel: channel
                                                                 }))
        JSON.parse(response.body)
      end
    end
  end
end

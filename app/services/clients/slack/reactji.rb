module Clients
  module Slack
    class Reactji < BaseSlack
      def send(reaction, channel, timestamp)
        url = build_url('/reactions')
        Request.post(url, authorization, build_params({
                                                        reaction: reaction,
                                                        channel: channel,
                                                        ts: timestamp
                                                      }))
      end
    end
  end
end

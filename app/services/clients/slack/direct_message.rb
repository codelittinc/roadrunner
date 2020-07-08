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
    end
  end
end

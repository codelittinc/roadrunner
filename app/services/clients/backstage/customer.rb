# frozen_string_literal: true

module Clients
  module Backstage
    class Customer < Client
      def get(id)
        response = request("/customers/#{id}")

        ::Customer.new(
          slack_api_key: response['notifications_token'],
          github_api_key: response['source_control_token']
        )
      end
    end
  end
end

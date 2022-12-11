# frozen_string_literal: true

module Clients
  module Notifications
    class Client
      def initialize(customer = nil)
        @customer = customer
        @key = customer&.slack_api_key || ENV.fetch('NOTIFICATIONS_API_KEY', nil)
        @url = ENV.fetch('NOTIFICATIONS_API_URL', nil)
      end

      def authorization
        "Bearer #{@key}"
      end

      def build_url(path)
        "#{@url}#{path}"
      end

      def request(path, body)
        url = build_url(path)
        SimpleRequest.post(url, authorization:, body:)
      end
    end
  end
end

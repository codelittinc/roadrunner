# frozen_string_literal: true

module Clients
  module Backstage
    class Client
      def initialize
        @url = ENV.fetch('BACKSTAGE_API_URL', nil)
        @key = ENV.fetch('BACKSTAGE_API_KEY', nil)
      end

      def authorization
        "Bearer #{@key}"
      end

      def build_url(path)
        "#{@url}#{path}"
      end

      def request(path)
        url = build_url(path)
        Request.get(url, authorization)
      end
    end
  end
end

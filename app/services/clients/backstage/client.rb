# frozen_string_literal: true

module Clients
  module Backstage
    class Client
      def initialize
        @key = ENV.fetch('BACKSTAGE_API_KEY', nil)
        @url = ENV.fetch('BACKSTAGE_API_URL', nil)
      end

      def authorization
        "Bearer #{@key}"
      end

      def build_url(path)
        "#{@url}#{path}"
      end

      def get(path)
        url = build_url(path)
        response = Request.post(url, authorization)
        JSON.parse(response.body) if response&.body
      end
    end
  end
end

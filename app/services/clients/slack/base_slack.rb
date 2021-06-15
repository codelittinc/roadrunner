# frozen_string_literal: true

module Clients
  module Slack
    class BaseSlack
      def initialize
        @bot = 'roadrunner'
        @key = ENV['NOTIFICATIONS_API_KEY']
        @url = ENV['NOTIFICATIONS_API_URL']
      end

      def build_params(params)
        {
          bot: @bot
        }.merge(params)
      end

      def authorization
        "Bearer #{@key}"
      end

      def build_url(path)
        "#{@url}#{path}"
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module Github
    class Hook < GithubBase
      PAYLOAD_URL = 'https://api.roadrunner.codelitt.dev/flows'
      CONTENT_TYPE = 'json'
      TRIGGER_EVENTS = %w[check_run pull_request pull_request_review push release].freeze
      SSL_VERIFICATION = '1'

      def list(repository)
        @client.hooks(repository)
      end

      def create(repository, name = 'web')
        @client.create_hook(repository, name, build_config, build_options)
      end

      private

      def build_config
        {
          content_type: CONTENT_TYPE,
          insecure_ssl: SSL_VERIFICATION,
          url: PAYLOAD_URL
        }
      end

      def build_options
        {
          active: true,
          events: TRIGGER_EVENTS
        }
      end
    end
  end
end

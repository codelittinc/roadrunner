# frozen_string_literal: true

module Clients
  module Github
    class Hook < GithubBase
      PAYLOAD_URL = 'https://api.roadrunner.codelitt.dev/flows'
      CONTENT_TYPE = 'json'
      TRIGGER_EVENTS = %w[check_run pull_request pull_request_review push release].freeze
      SSL_VERIFICATION = '1'

      def list(repository)
        @client.hooks(repository.full_name)
      end

      def create(repository, name = 'web')
        @client.create_hook(repository.full_name, name, build_config, build_options)
      rescue Octokit::UnprocessableEntity
        { status: 200 }
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

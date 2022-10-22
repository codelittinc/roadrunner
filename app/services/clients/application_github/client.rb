# frozen_string_literal: true

module Clients
  module ApplicationGithub
    class Client
      attr_reader :client

      def initialize(installation_id)
        @installation_id = installation_id
        @client = Octokit::Client.new(access_token:)
      end

      def access_token
        accept = 'application/vnd.github.machine-man-preview+json'

        # Use a temporary JWT to get an access token, scoped to the integration's installation.
        headers = { 'Authorization' => "Bearer #{jwt_token}", 'Accept' => accept }
        access_tokens_url = "/app/installations/#{@installation_id}/access_tokens"
        access_tokens_response = Octokit::Client.new.post(access_tokens_url, headers:)
        access_tokens_response[:token]
      end

      # Generate the JWT required for the initial GitHub Integrations API handshake.
      # https://developer.github.com/early-access/integrations/authentication/#as-an-integration
      def jwt_token
        private_pem = ENV.fetch('GITHUB_PRIVATE_KEY', nil) # File.read('./app.key')
        private_key = OpenSSL::PKey::RSA.new(private_pem)
        now = Time.now.to_i
        payload = {
          iat: now, # Issued at time.
          exp: now + (10 * 60), # JWT expiration time.
          iss: ENV.fetch('GITHUB_APP_ID', nil).to_s # Integration's GitHub identifier.
        }
        JWT.encode(payload, private_key, 'RS256')
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module ApplicationGithub
    class Organization < Client
      def get
        authorization = "Bearer #{jwt_token}"
        response = Request.get("https://api.github.com/app/installations/#{@installation_id}", authorization:)
        response['account']
      end
    end
  end
end

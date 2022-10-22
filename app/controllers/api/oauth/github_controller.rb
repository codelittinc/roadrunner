# frozen_string_literal: true

module Api
  module Oauth
    class GithubController < ApplicationController
      def create
        organization = Organization.find(params['state'])
        GithubInstallation.find_or_create_by(organization:, installation_id:)

        render json: { params: }, status: :ok
      end

      private

      def organization_id
        params['state']
      end

      def installation_id
        params['installation_id']
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module Oauth
    class GithubController < ApplicationController
      def create
        organization = Organization.find(params['state'])
        installation = GithubInstallation.find_or_initialize_by(organization:, installation_id:)
        installation.name = Clients::ApplicationGithub::Organization.new(installation_id).get['login']
        installation.save!

        InstallationRepositoriesCreator.new(installation.id).call

        redirect_to organization_path(organization)
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

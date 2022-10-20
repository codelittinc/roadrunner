# frozen_string_literal: true

module Clients
  module ApplicationGithub
    class Repository < Client
      def list
        repositories = @client.list_app_installation_repositories.repositories

        repositories.map do |repo|
          Clients::Github::Parsers::RepositoryParser.new(repo)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module ApplicationGithub
    class Repository < Client
      MAX_PER_PAGE = 100
      def list
        repositories = get_all_repositories(1)

        repositories.map do |repo|
          Clients::Github::Parsers::RepositoryParser.new(repo)
        end
      end

      private

      def get_all_repositories(page, repositories = nil)
        new_repositories = @client.list_app_installation_repositories({ per_page: MAX_PER_PAGE, page: }).repositories

        all_repositories = (repositories || []) + new_repositories

        get_all_repositories(page + 1, all_repositories) if new_repositories.size >= MAX_PER_PAGE

        all_repositories
      end
    end
  end
end

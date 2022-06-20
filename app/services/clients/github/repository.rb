# frozen_string_literal: true

module Clients
  module Github
    class Repository < GithubBase
      def get_repository(repository)
        repository = @client.repository(repository.full_name)
        Clients::Github::Parsers::RepositoryParser.new(repository)
      end

      def repositories(owner)
        limit = 100

        page = 1
        temp_repos = list_repositories(page)
        repos = []

        while temp_repos.size >= limit
          repos << temp_repos
          repos = repos.flatten
          page += 1
          temp_repos = list_repositories(page)
        end

        repos = repos.map do |repo|
          Clients::Github::Parsers::RepositoryParser.new(repo)
        end

        repos = repos.reject(&:archived)

        return repos if owner.blank?

        repos.select do |repo|
          repo.owner == owner
        end
      end

      private

      def list_repositories(page)
        @client.repositories({}, query: { per_page: 100, page: })
      end
    end
  end
end

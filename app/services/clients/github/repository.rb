# frozen_string_literal: true

module Clients
  module Github
    class Repository < GithubBase
      def get_repository(repository)
        repository = @client.repository(repository.full_name)
        Clients::Github::Parsers::RepositoryParser.new(repository)
      end
    end
  end
end

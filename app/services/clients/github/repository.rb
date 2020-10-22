# frozen_string_literal: true

module Clients
  module Github
    class Repository < GithubBase
      def get_repository(repository)
        @client.repository(repository)
      end
    end
  end
end

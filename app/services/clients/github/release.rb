module Clients
  module Github
    class Release < GithubBase
      def list(repository)
        @client.list_releases(repository)
      end
    end
  end
end

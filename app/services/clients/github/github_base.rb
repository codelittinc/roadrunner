module Clients
  module Github
    class GithubBase
      def initialize
        @client = Octokit::Client.new(access_token: ENV['GIT_AUTH_KEY'])
      end
    end
  end
end

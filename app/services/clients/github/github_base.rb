# frozen_string_literal: true

module Clients
  module Github
    class GithubBase
      def initialize
        @client = Octokit::Client.new(access_token: ENV.fetch('GIT_AUTH_KEY', nil))
      end
    end
  end
end

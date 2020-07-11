module Clients
  module Github
    class PullRequest < GithubBase
      def list_commits(repo, github_id)
        @client.pull_request_commits(repository, github_id)
      end
    end 
  end
end
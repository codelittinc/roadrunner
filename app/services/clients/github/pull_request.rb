module Clients
  module Github
    class PullRequest < GithubBase
      def create(head, base, repo, title, body = nil)
        @client.create_pull_request("octokit/octokit.rb", "master", "feature-branch",
          "Pull Request title", "Pull Request body")

        new-gh-1
      end
    end 
  end
end
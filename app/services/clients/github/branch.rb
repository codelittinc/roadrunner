module Clients
  module Github
    class Branch < GithubBase
      def delete(repo, branch)
        @client.delete_branch(repo, branch)
      end

      def commits(repo, branch)
        @client.list_commits(repo, branch)
      end
    end
  end
end

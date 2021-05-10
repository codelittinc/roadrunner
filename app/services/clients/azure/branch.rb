# frozen_string_literal: true

module Clients
  module Azure
    class Branch < AzureBase
      def commits(repo, branch)
        url = "#{azure_url}git/repositories/#{repo}/commits?searchCriteria.itemVersion.version=#{branch}&api-version=4.1"
        response = Request.get(url, authorization)
        commits = response['value']
        commits.map do |commit|
          Clients::Azure::Parsers::CommitParser.new(commit)
        end
      end

      def compare(repo, head, base)
        url = "#{azure_url}git/repositories/#{repo}/diffs/commits?baseVersion=#{base}&baseVersionType=branch&targetVersion=#{head}&targetVersionType=branch&api-version=4.1"
        response = Request.get(url, authorization)
        response['changes']
      end

      def branch_exists?(repo, branch)
        url = "#{azure_url}git/repositories/#{repo}/refs?filter=heads/#{branch}&api-version=4.1"
        response = Request.get(url, authorization)
        response['count'].positive?
      end
    end
  end
end

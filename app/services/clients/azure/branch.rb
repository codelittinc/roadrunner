# frozen_string_literal: true

module Clients
  module Azure
    class Branch < AzureBase
      def commits(repository, branch)
        url = "#{azure_url}git/repositories/#{repository.name}/commits?searchCriteria.itemVersion.version=#{branch}&api-version=4.1"
        response = Request.get(url, authorization)
        commits = response['value']
        commits.map do |commit|
          Clients::Azure::Parsers::CommitParser.new(commit)
        end
      end

      def compare(repository, head, base)
        baseVersionType = head.match?(/^rc|^v/) ? 'tag' : 'branch'
        url = "#{azure_url}git/repositories/#{repository.name}/diffs/commits?baseVersion=#{head}&baseVersionType=#{baseVersionType}&targetVersion=#{base}&targetVersionType=branch&api-version=4.1"
        response = Request.get(url, authorization)
        commits = response['changes']
        commits.map do |commit|
          Clients::Azure::Parsers::CommitParser.new(commit)
        end
      end

      def branch_exists?(repository, branch)
        url = "#{azure_url}git/repositories/#{repository.name}/refs?filter=heads/#{branch}&api-version=4.1"
        response = Request.get(url, authorization)
        response['count'].positive?
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module Azure
    class Branch < AzureBase
      def commits(repository, branch)
        type = %w[master main].include?(branch) ? 'branch' : 'commit'
        type = 'tag' if branch.match?(/rc.\d|^v\d/)
        url = "#{azure_url}git/repositories/#{repository.name}/commits?searchCriteria.itemVersion.version=#{branch}&api-version=6.1-preview.1&searchCriteria.itemVersion.versionType=#{type}"
        # url = "#{azure_url}git/repositories/#{repository.name}/commits?searchCriteria.itemVersion.version=#{branch}&api-version=4.1"
        response = Request.get(url, authorization)
        commits = response['value']
        commits.map do |commit|
          Clients::Azure::Parsers::CommitParser.new(commit)
        end
      end

      def compare(repository, head, base)
        base_version_type = head.match?(/^rc|^v/) ? 'tag' : 'branch'
        target_version_type = base.match?(/^rc|^v/) ? 'tag' : 'branch'
        url = "#{azure_url}git/repositories/#{repository.name}/diffs/commits?baseVersion=#{head}&baseVersionType=#{base_version_type}&targetVersion=#{base}&targetVersionType=#{target_version_type}&api-version=6.0"
        response = Request.get(url, authorization)
        commits = response['changes']
        commits.map do |commit|
          sha = commit['item']['commitId']
          azure_commit_url = "#{azure_url}git/repositories/#{repository.name}/commits/#{sha}?api-version=6.0"
          response = Request.get(azure_commit_url, authorization)

          Clients::Azure::Parsers::CommitParser.new(response)
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

# frozen_string_literal: true

module Clients
  module Azure
    class Branch < AzureBase
      def commits(repository, branch)
        type = resource_type(branch)
        url = "#{azure_url}git/repositories/#{repository.name}/commits?searchCriteria.itemVersion.version=#{branch}&api-version=6.1-preview.1&searchCriteria.itemVersion.versionType=#{type}"
        # url = "#{azure_url}git/repositories/#{repository.name}/commits?searchCriteria.itemVersion.version=#{branch}&api-version=4.1"
        response = Request.get(url, authorization)
        commits = response['value']
        commits.map do |commit|
          Clients::Azure::Parsers::CommitParser.new(commit)
        end
      end

      def compare(repository, head, base)
        head_commits = commits(repository, head)
        base_commits = commits(repository, base)

        head_commits.filter do |head_commit|
          !base_commits.find do |base_commit|
            base_commit.sha == head_commit.sha
          end
        end
      end

      def branch_exists?(repository, branch)
        url = "#{azure_url}git/repositories/#{repository.name}/refs?filter=heads/#{branch}&api-version=4.1"
        response = Request.get(url, authorization)
        response['count'].positive?
      end

      def resource_type(resource)
        return 'commit' if sha?(resource)
        return 'tag' if tag?(resource)

        'branch'
      end

      def sha?(sha)
        sha.match?(/\b[0-9a-f]{5,40}\b/)
      end

      def tag?(tag)
        tag.match?(/^rc|^v/)
      end
    end
  end
end

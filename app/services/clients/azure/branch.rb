# frozen_string_literal: true

module Clients
  module Azure
    class Branch < AzureBase
      def commits(repository, branch, from_date = nil)
        type = resource_type(branch)
        url = "#{azure_url(repository)}git/repositories/#{repository.name}/commits?searchCriteria.itemVersion.version=#{branch}&api-version=6.1-preview.1&searchCriteria.itemVersion.versionType=#{type}"
        url = "#{url}&&searchCriteria.fromDate=#{from_date}" unless from_date.nil?
        response = Request.get(url, authorization(repository))
        commits = response['value']
        commits.map do |commit|
          Clients::Azure::Parsers::CommitParser.new(commit)
        end
      end

      def compare(repository, head, base)
        head_commits = commits(repository, head)
        date_last_head_commit = (head_commits.first.date.to_datetime + 1.second)
        date_base_filter = date_last_head_commit.strftime('%Y-%m-%d %H:%M:%S')
        comm = commits(repository, base, date_base_filter)
        comm.reverse
      end

      def branch_exists?(repository, branch)
        url = "#{azure_url(repository)}git/repositories/#{repository.name}/refs?filter=heads/#{branch}&api-version=4.1"
        response = Request.get(url, authorization(repository))
        response['count'].positive?
      end

      def resource_type(resource)
        return 'commit' if sha?(resource)
        return 'tag' if tag?(resource)

        'branch'
      end

      def sha?(sha)
        sha.match?(/\b[0-9a-f]{40}\b/)
      end

      def tag?(tag)
        tag.match?(/^rc|^v/)
      end
    end
  end
end

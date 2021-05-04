# frozen_string_literal: true

module Clients
  module Azure
    class PullRequest < AzureBase
      def get(repository, source_control_id)
        url = "#{azure_url}#{repository}/pullrequests/#{source_control_id}"
        Request.get(url, authorization)
      end

      def list_commits(repository, source_control_id)
        url = "#{azure_url}#{repository}/pullrequests/#{source_control_id}?api-version=6.0&includeCommits=true"
        response = Request.get(url, authorization)
        response['commits']
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module Azure
    class Branch < AzureBase
      def commits(repo, branch)
        url = "#{azure_url}git/repositories/#{repo}/commits?searchCriteria.itemVersion.version=#{branch}&api-version=4.1"
        response = Request.get(url, authorization)
        response['value']
      end
    end
  end
end

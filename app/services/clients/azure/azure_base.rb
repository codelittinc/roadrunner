# frozen_string_literal: true

module Clients
  module Azure
    class AzureBase
      def azure_url(repository)
        metadata = repository.external_project.metadata
        azure_project_name = metadata['azure_project_name']
        azure_owner = metadata['azure_owner']

        "https://dev.azure.com/#{azure_owner}/#{azure_project_name}/_apis/"
      end

      def authorization(repository)
        project = repository.external_project
        key = ":#{project.customer.github_api_key}"
        base64_key = Base64.urlsafe_encode64(key)
        "Basic #{base64_key}"
      end
    end
  end
end

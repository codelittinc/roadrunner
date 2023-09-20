# frozen_string_literal: true

module Clients
  module Azure
    class AzureBase
      def azure_url(repository)
        owner = repository.owner
        # @TODO: allow this to be configurable. A major pain point is in the azure_parser because we need to get the repository to get the owner.
        # in that part, we need o find a way to get the owner or the repository differently.
        owner ||= if AzurePullRequest::AZURE_OWNER == 'AY-InnovationCenter'
                    'Avant'
                  else
                    'ministrybrands'
                  end
        "https://dev.azure.com/#{AzurePullRequest::AZURE_OWNER}/#{owner}/_apis/"
      end

      def azure_api_url
        "https://vsrm.dev.azure.com/#{AzurePullRequest::AZURE_OWNER}/Avant/_apis/"
      end

      def authorization
        key = ":#{ENV.fetch('AZURE_AUTH_KEY', nil)}"
        base64_key = Base64.urlsafe_encode64(key)
        "Basic #{base64_key}"
      end
    end
  end
end

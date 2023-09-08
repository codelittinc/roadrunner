# frozen_string_literal: true

module Clients
  module Azure
    class AzureBase
      # @TODO: allow this to be configurable
      def azure_url
        'https://dev.azure.com/codelitt-kaio/roadrunner/_apis/'
      end

      def azure_api_url
        'https://vsrm.dev.azure.com/codelitt-kaio/roadrunner/_apis/'
      end

      def authorization
        key = ":#{ENV.fetch('AZURE_AUTH_KEY', nil)}"
        base64_key = Base64.urlsafe_encode64(key)
        "Basic #{base64_key}"
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module Azure
    class AzureBase
      def azure_url
        'https://dev.azure.com/AY-InnovationCenter/Avant/_apis/'
      end

      def azure_api_url
        'https://vsrm.dev.azure.com/AY-InnovationCenter/Avant/_apis/'
      end

      def authorization
        "Basic #{ENV['AZURE_AUTH_KEY']}"
      end
    end
  end
end

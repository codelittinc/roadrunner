# frozen_string_literal: true

module Clients
  module Azure
    class AzureBase
      def azure_url
        'https://dev.azure.com/AY-InnovationCenter/Avant/_apis/git/repositories/'
      end

      def authorization
        "Basic #{ENV['AZURE_AUTH_KEY']}"
      end
    end
  end
end

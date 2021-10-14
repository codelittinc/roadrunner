# frozen_string_literal: true

module Clients
  module Azure
    class Sprint < AzureBase
      def list(team)
        url = "https://dev.azure.com/AY-InnovationCenter/Avant/#{team}/_apis/work/teamsettings/iterations?api-version=6.0"
        sprints = Request.get(url, authorization)
        sprints['value'].map do |obj|
          Clients::Azure::Parsers::SprintParser.new(obj)
        end
      end
    end
  end
end

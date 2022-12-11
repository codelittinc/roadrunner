# frozen_string_literal: true

module Clients
  module Azure
    class Sprint < AzureBase
      def list(team, time_frame = nil)
        url = "https://dev.azure.com/AY-InnovationCenter/Avant/#{team}/_apis/work/teamsettings/iterations?api-version=6.0"
        sprints = SimpleRequest.get(url, authorization:)
        sprints['value'].map do |obj|
          parsed_sprint = Clients::Azure::Parsers::SprintParser.new(obj)

          parsed_sprint if !time_frame || parsed_sprint.time_frame == time_frame
        end.compact
      end

      def work_items(team, id)
        url = "https://dev.azure.com/AY-InnovationCenter/Avant/#{team}/_apis/work/teamsettings/iterations/#{id}/workitems?api-version=6.0-preview.1"
        sprint = SimpleRequest.get(url, authorization:)
        work_items = sprint['workItemRelations']
        work_items.map do |wi|
          wi_url = wi['target']['url']
          response = SimpleRequest.get(wi_url, authorization:)
          Clients::Azure::Parsers::WorkItemParser.new(response)
        end
      end
    end
  end
end

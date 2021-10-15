# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class WorkItemParser
        attr_reader :story_type, :state, :title, :assigned_to, :story_points

        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!
          fields = @json[:fields]
          @story_type = fields['System.WorkItemType']
          @assigned_to = fields.dig('System.AssignedTo', 'id')
          @state = fields['System.BoardColumn']
          @title = fields['System.Title']
          @story_points = fields['Microsoft.VSTS.Scheduling.StoryPoints']
          @json = nil
        end
      end
    end
  end
end

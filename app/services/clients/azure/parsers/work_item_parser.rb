# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class WorkItemParser < ClientParser
        attr_reader :story_type, :state, :title, :assigned_to, :story_points, :display_name, :tags

        def parse!
          fields = @json[:fields]
          @story_type = fields['System.WorkItemType']
          @assigned_to = fields.dig('System.AssignedTo', 'id')
          @display_name = fields.dig('System.AssignedTo', 'displayName')
          @state = fields['System.BoardColumn']
          @title = fields['System.Title']
          @story_points = fields['Microsoft.VSTS.Scheduling.StoryPoints']
          @tags = fields['System.Tags']
          @json = nil
        end
      end
    end
  end
end

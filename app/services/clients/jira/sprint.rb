# frozen_string_literal: true

module Clients
  module Jira
    class Sprint < JiraBase
      def list(board_id)
        sprints_url = build_agile_url("/board/#{board_id}/sprint")
        body = Request.get(sprints_url, authorization)
        body['values'] || []
      end
    end
  end
end

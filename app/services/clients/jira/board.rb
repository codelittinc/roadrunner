# frozen_string_literal: true

module Clients
  module Jira
    class Board < JiraBase
      def list
        boards_url = build_agile_url('/board')
        body = Request.get(boards_url, authorization)
        body['values']
      end
    end
  end
end

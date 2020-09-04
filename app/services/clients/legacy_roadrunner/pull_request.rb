# frozen_string_literal: true

module Clients
  module LegacyRoadrunner
    class PullRequest
      URL = 'https://roadrunner.codelitt.dev'

      def self.by_github_id_and_repository(github_id, repository)
        url = build_url("pull-requests/#{github_id}/#{repository}")
        response = Request.get(url)
      end

      def self.build_url(path)
        "#{URL}/#{path}"
      end
    end
  end
end

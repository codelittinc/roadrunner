# frozen_string_literal: true

module Clients
  module Jira
    class Issue < JiraBase
      def list(project_id, status_name, max_results = 100, start_at = 0)
        status = status_name.gsub(' ', '%20')
        projects_url = build_api_url("/search?jql=project%20%3D%20#{project_id}%20AND%20status%20%3D%20\"#{status_name}\"&maxResults=#{max_results}&startAt=#{start_at}")
        body = Request.get(projects_url, authorization)
        body['issues']
      end

      def list_all(project_id, max_results = 100, start_at = 0)
        projects_url = build_api_url("/search?jql=project%20%3D%20#{project_id}&maxResults=#{max_results}&startAt=#{start_at}")
        body = Request.get(projects_url, authorization)
        body['issues']
      end

      def update_status(issue_key, status_name)
        url = build_api_url("/issue/#{issue_key}/transitions?expand=expand.fields")
        status = Clients::Jira::Status.new.list_by_issue(issue_key, status_name)[0]
        body = Request.post(url, authorization, {
                              "transition": {
                                "id": status['id']
                              }
                            })
      end
    end
  end
end

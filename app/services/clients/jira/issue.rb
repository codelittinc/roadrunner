module Clients
  module Jira
    class Issue < JiraBase
      def list(project_id, status_name)
        status = status_name.gsub(' ', '%20')
        projects_url = build_url("/search?jql=project%20%3D%20#{project_id}%20AND%20status%20%3D%20\"#{status_name}\"&fields=status,id")
        body = Request.get(projects_url, authorization)
        body["issues"];
      end

      def self.build_url key
        "https://codelitt.atlassian.net/browse/#{key}"
      end
    end 
  end
end
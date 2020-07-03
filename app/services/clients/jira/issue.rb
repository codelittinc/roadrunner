module Clients
  module Jira
    class Issue < JiraBase
      def list(project_id, status_name)
        status = status_name.gsub(' ', '%20')
        projects_url = build_api_url("/search?jql=project%20%3D%20#{project_id}%20AND%20status%20%3D%20\"#{status_name}\"&fields=status,id")
        body = Request.get(projects_url, authorization)
        body["issues"];
      end

      def update_status(issue_key, status_name)
         url = build_api_url("/issue/#{issue_key}/transitions?expand=expand.fields")
         status = Clients::Jira::Status.new.list_by_issue(issue_key, status_name)[0]
         body = Request.post(url, authorization, {
          "transition": {
            "id": status["id"]
          }
        })
      end
    end 
  end
end
module Clients
  module Jira
    class Project < JiraBase
      def list
        projects_url = build_api_url('/project/search')
        body = Request.get(projects_url, authorization)
        body["values"];
      end 
    end 
  end
end
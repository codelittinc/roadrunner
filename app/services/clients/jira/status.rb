module Clients
  module Jira
    class Status < JiraBase
      def list_by_issue(issue_key, name = nil)
        statuses_url = build_api_url("/issue/#{issue_key}/transitions?expand=expand.fields")
        body = Request.get(statuses_url, authorization)
        statuses = body['transitions']

        return statuses unless name

        formatted_name = name.downcase

        statuses.select do |status|
          status['name'].downcase == formatted_name ||
          status["to"]["name"].downcase == formatted_name
        end
      end 
    end 
  end
end
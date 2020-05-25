module Clients
  module Jira
    class Status < JiraBase
      def list(project_id, name = nil)
        statuses_url = build_url("/project/#{project_id}/statuses")
        body = Request.get(statuses_url, authorization)
        statuses = body[0]['statuses']

        return statuses unless name

        statuses.select do |status|
          status['name'].downcase == name.downcase
        end
      end 
    end 
  end
end
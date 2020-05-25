module Clients
  module Jira
    class JiraBase
      BASE_URL = 'https://codelitt.atlassian.net/rest/api/3'

      def initialize
        @auth_key = ENV['JIRA_AUTH_KEY']
      end

      def build_url path
        "#{BASE_URL}#{path}"
      end
  
      def authorization 
        "Basic #{@auth_key}"
      end
    end 
  end
end
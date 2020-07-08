module Clients
  module Jira
    class JiraBase
      BASE_API_URL = 'https://codelitt.atlassian.net/rest/api/3'.freeze
      BASE_BROWSER_URL = 'https://codelitt.atlassian.net/browse/'.freeze

      def initialize
        @auth_key = 'a2Fpb0Bjb2RlbGl0dC5jb206UHpuRkJIQUhPRENDc01kelVHbEU4MTFB'
      end

      def build_api_url(path)
        "#{BASE_API_URL}#{path}"
      end

      def build_browser_url(path)
        "#{BASE_BROWSER_URL}#{path}"
      end

      def authorization
        "Basic #{@auth_key}"
      end
    end
  end
end

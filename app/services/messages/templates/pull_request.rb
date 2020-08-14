module Messages
  module Templates
    class PullRequest
      NEW_PULL_REQUEST = '%s :point_right:  please review the pull request <%s|%s#%i>'.freeze
      CLOSE_PULL_REQUEST_NOTIFICATION = ':merge2: Pull Request closed <%s|%s#%i>'.freeze
      NEW_CHANGE_PULL_REQUEST_NOTIFICATION = ':pencil2: There is a new change!'.freeze
      NOTIFY_CI_FAILURE = ':rotating_light: CI failed for pull request: <%s|%s#%i> '.freeze
    end
  end
end

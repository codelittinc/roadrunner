# frozen_string_literal: true

module Messages
  module Templates
    class PullRequest
      NEW_PULL_REQUEST = '%s :point_right:  please review the pull request <%s|%s#%i>'
      CLOSE_PULL_REQUEST_NOTIFICATION = ':merge2: Pull Request closed <%s|%s#%i>'
      NEW_CHANGE_PULL_REQUEST_NOTIFICATION = ':pencil2: There is a new change!'
      NOTIFY_CI_FAILURE = ':rotating_light: CI failed for pull request: <%s|%s#%i>'
      PULL_REQUEST_CONFLICTS = ':boom: there are conflicts on this Pull Request: <%s|%s#%i>'
    end
  end
end

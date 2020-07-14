module Messages
  class Builder
    def self.new_pull_request_message(pull_request)
      repository = pull_request.repository
      slack_group = repository.slack_repository_info.dev_group

      link = pull_request.github_link

      format(Templates::PullRequest::NEW_PULL_REQUEST, slack_group, link, repository.name, pull_request.github_id)
    end

    def self.close_pull_request_message(pull_request)
      "~#{new_pull_request_message(pull_request)}~"
    end
  end
end

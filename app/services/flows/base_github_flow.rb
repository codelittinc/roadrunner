# frozen_string_literal: true

module Flows
  class BaseGithubFlow < BaseFlow
    def repository
      @repository ||= Repository.find_by(name: parser.repository_name, owner: parser.owner)
    end

    def pull_request_exists?
      PullRequest.by_repository_and_source_control_id(repository, parser.source_control_id)
    end

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end
  end
end

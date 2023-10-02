# frozen_string_literal: true

module Flows
  class BaseSourceControlFlow < BaseFlow
    def repository
      @repository ||= Repository.where('lower(name) = ? and owner = ? and active = true', parser.repository_name.downcase, parser.owner).first
    end

    def customer
      @customer ||= repository.project.customer
    end

    def pull_request
      @pull_request ||= PullRequest.by_repository_and_source_control_id(repository, parser.source_control_id)
    end

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end

    def pull_request_user
      @pull_request_user ||= pull_request.user
    end

    def slack_username
      @slack_username ||= pull_request_user.slack
    end

    def action
      @params[:action]
    end
  end
end

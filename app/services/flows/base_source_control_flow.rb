# frozen_string_literal: true

module Flows
  class BaseSourceControlFlow < BaseFlow
    def repository
      return nil if parser.repository_name.blank?

      @repository ||= Repository.by_name(parser.repository_name).where(owner: parser.owner, active: true).first
    end

    def customer
      return @customer if @customer

      @customer = repository.mesh_project&.customer
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

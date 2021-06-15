# frozen_string_literal: true

require 'ostruct'

module Parsers
  class GithubWebhookParser < BaseParser
    delegate :body, :state, to: :review, prefix: true, allow_nil: true
    attr_reader :base, :branch_name, :description, :draft, :source_control_id, :head, :merged, :owner, :repository_name, :review, :review_username, :state, :title, :username, :action

    def source_control_pull_request
      Clients::Github::PullRequest
    end

    def can_parse?
      @json && (!!pull_request || !!checkrun)
    end

    def new_pull_request_flow?
      action == 'opened' || action == 'ready_for_review'
    end

    def close_pull_request_flow?
      action == 'closed'
    end

    def new_review_submission_flow?
      action == 'submitted'
    end

    def destroy_branch!(pull_request)
      Clients::Github::Branch.new.delete(pull_request.repository, pull_request.head)
    end

    def parse!
      parse_pull_request! if pull_request

      @owner = @json.dig(:organization, :login) || @json.dig(:pull_request, :head, :repo, :owner, :login)
      @repository_name = @json.dig(:repository, :name)
      @username = @json.dig(:sender, :login).downcase
      @review = OpenStruct.new @json[:review]
      @review_username = review&.dig(:user, :login)
      @action = @json[:action]
    end

    def user_by_source_control
      User.find_or_initialize_by(github: username)
    end

    def build_source(pull_request)
      GithubPullRequest.new(source_control_id: source_control_id, pull_request: pull_request)
    end

    private

    def parse_pull_request!
      @base = pull_request&.dig(:base, :ref)
      @description = pull_request&.dig(:body)
      @draft = pull_request&.dig(:draft)
      @source_control_id = pull_request&.dig(:number)
      @head = pull_request&.dig(:head, :ref)
      @merged = !pull_request[:merged_at]&.empty?
      @state = pull_request&.dig(:state)
      @title = pull_request&.dig(:title)
    end

    def pull_request
      @json[:pull_request]
    end

    def checkrun
      @json[:check_run]
    end
  end
end

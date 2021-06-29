# frozen_string_literal: true

require 'ostruct'

module Parsers
  class AzureWebhookSourceControlParser < BaseParser
    attr_reader :base, :branch_name, :description, :draft, :source_control_id, :head, :merged, :owner, :repository_name, :review, :review_username, :state, :title, :username, :event_type, :commit_sha, :conclusion

    def can_parse?
      @json[:publisherId] == 'tfs'
    end

    def source_control_pull_request
      Clients::Azure::PullRequest
    end

    def new_pull_request_flow?
      event_type == 'git.pullrequest.created' || event_type == 'git.pullrequest.updated'
    end

    def close_pull_request_flow?
      (event_type == 'git.pullrequest.merged' || event_type == 'git.pullrequest.updated') && (@status == 'completed' || @status == 'abandoned')
    end

    def new_review_submission_flow?
      event_type == 'ms.vss-code.git-pullrequest-comment-event'
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/AbcSize
    def parse!
      parse_check_run! if check_run

      @event_type = @json[:eventType]
      @base = resource[:targetRefName]&.scan(%r{/.+/(.+$)})&.flatten&.first
      @description = resource[:description]
      @source_control_id = resource[:pullRequestId] || resource.dig(:pullRequest, :pullRequestId)
      @draft = resource[:isDraft]
      @head = resource[:sourceRefName]&.scan(%r{/.*/(.+/.+$)})&.flatten&.first
      @owner = resource.dig(:repository, :project, :name) || resource.dig(:pullRequest, :repository, :project, :name)
      @repository_name = resource.dig(:repository, :name) || resource.dig(:pullRequest, :repository, :name)
      @title = resource[:title]
      @username = resource.dig(:createdBy, :uniqueName)
      @merged = resource[:mergeStatus] == 'succeeded'
      @status = resource[:status]
      @review = resource[:comment]
      @review_username = @review&.dig(:author, :uniqueName)
      @review_body = @review&.dig(:content)
      # @TODO: check if it is even possible to have this from Azure
      @review_state = ''
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize

    # @TODO: add tests
    def user_by_source_control
      User.find_or_initialize_by(azure: username)
    end

    def build_source(pull_request)
      AzurePullRequest.new(source_control_id: source_control_id, pull_request: pull_request)
    end

    private

    def resource
      @json[:resource]
    end

    def check_run
      resource[:run]
    end

    def parse_check_run!
      @commit_sha = check_run&.dig(:resources, :repositories, :self, :version)
      @branch_name = check_run&.dig(:resources, :repositories, :self, :refName)
      @conclusion = check_run[:result] == 'succeeded' ? 'success' : 'failure'
    end
  end
end

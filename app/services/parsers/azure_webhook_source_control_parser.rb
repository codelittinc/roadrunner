# frozen_string_literal: true

require 'ostruct'

module Parsers
  class AzureWebhookSourceControlParser < BaseParser
    delegate :body, :state, to: :review, prefix: true, allow_nil: true
    attr_reader :base, :branch_name, :description, :draft, :source_control_id, :head, :merged_at, :owner, :repository_name, :review, :review_username, :state, :title, :username, :event_type

    def can_parse?
      @json[:publisherId] == 'tfs'
    end

    def new_pull_request_flow?
      event_type == 'git.pullrequest.created'
    end

    def parse!
      @event_type = @json[:eventType]
      @base = resource[:targetRefName].scan(%r{/.+/(.+$)}).flatten.first
      @description = resource[:description]
      @source_control_id = resource[:pullRequestId]
      @draft = resource[:isDraft]
      @head = resource[:sourceRefName].scan(%r{/.*/(.+/.+$)}).flatten.first
      @owner = resource.dig(:repository, :project, :name)
      @repository_name = resource.dig(:repository, :name)
      @title = resource[:title]
      @username = resource.dig(:createdBy, :uniqueName)
      # @TODO: implement the fields below
      # @merged_at = pull_request[:merged_at]
      # @review = OpenStruct.new @json[:review]
      # @review_username = review&.dig(:user, :login)
      # @state = pull_request[:state]
    end

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
  end
end

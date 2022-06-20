# frozen_string_literal: true

require 'ostruct'

module Parsers
  class AzureWebhookSourceControlParser < BaseAzureParser
    attr_reader :base, :branch_name, :description, :draft, :source_control_id, :head, :merged, :owner,
                :repository_name, :state, :title, :username, :event_type, :commit_sha, :conclusion

    def can_parse?
      @json[:publisherId] == 'tfs' || @json[:publisherId] == 'pipelines'
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

    def parse!
      parse_check_run! if check_run

      @event_type = @json[:eventType]
      @base = real_branch_name(resource[:targetRefName])
      @description = resource[:description]
      @source_control_id = resource[:pullRequestId] || resource.dig(:pullRequest, :pullRequestId)
      @draft = resource[:isDraft]
      @head = real_branch_name(resource[:sourceRefName])
      @owner = @owner || resource.dig(:repository, :project,
                                      :name) || resource.dig(:pullRequest, :repository, :project, :name)
      @repository_name = @repository_name || resource.dig(:repository,
                                                          :name) || resource.dig(:pullRequest, :repository, :name)
      @title = resource[:title]
      @username = resource.dig(:createdBy, :uniqueName)
      @merged = resource[:mergeStatus] == 'succeeded'
      @status = resource[:status]
    end

    # @TODO: add tests
    def user_by_source_control(customer)
      User.find_or_initialize_by(azure: username, customer:)
    end

    def build_source(pull_request)
      AzurePullRequest.new(source_control_id:, pull_request:)
    end

    def check_run
      resource[:run]
    end

    def parse_check_run!
      @commit_sha = check_run&.dig(:resources, :repositories, :self, :version)
      branch = check_run&.dig(:resources, :repositories, :self, :refName)
      branch_name_regex = %r{refs/heads/(.*)}
      @branch_name = branch.match?(branch_name_regex) ? branch.match(branch_name_regex)[1] : nil
      @conclusion = check_run[:result] == 'succeeded' ? 'success' : 'failure'
      repository_id = check_run&.dig(:resources, :repositories, :self, :repository, :id)
      repository = OpenStruct.new({ name: repository_id })
      repo = Clients::Azure::Repository.new.get_repository(repository)
      @repository_name = repo.name
      @owner = repo.owner
    end

    private

    def resource
      @json[:resource]
    end
  end
end

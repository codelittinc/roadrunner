# frozen_string_literal: true

module Flows
  class CheckRunFlow < BaseFlow
    def execute
      branch = Branch.where(name: branch_name, repository: repository).first_or_create!(pull_request: pull_request)
      CheckRun.create(commit_sha: commit_sha, state: state, branch: branch)

      return unless pull_request

      if state == CheckRun::FAILURE_STATE
        notify_ci_failure_message = Messages::PullRequestBuilder.notify_ci_failure(pull_request)
        Clients::Slack::DirectMessage.new.send(
          notify_ci_failure_message,
          pull_request.user.slack
        )
      end

      pull_request&.update(ci_state: state)

      Clients::Slack::Reactji.new.send(reaction, channel, message.ts)
    end

    def flow?
      return false unless check_run
      return false if branch_name.to_s.empty?

      commit_sha && (state == CheckRun::FAILURE_STATE || state == CheckRun::SUCCESS_STATE || state == CheckRun::PENDING_STATE)
    end

    private

    def repository
      @repository ||= Repository.where(name: @params.dig(:repository, :name)).last
    end

    def pull_request
      @pull_request ||= PullRequest.where(repository: repository, head: branch_name, state: 'open').last
    end

    def message
      @message = pull_request.slack_message
    end

    def check_run
      @check_run ||= @params[:check_run]
    end

    def state
      CheckRun::SUPPORTED_STATES.find { |i| i == check_run[:conclusion] } || CheckRun::PENDING_STATE
    end

    def branch_name
      @branch_name ||= check_run.dig(:check_suite, :head_branch)
    end

    def commit_sha
      @commit_sha ||= check_run[:head_sha]
    end

    def reaction
      reacts = { 'success' => 'white_check_mark',
                 'failure' => 'rotating_light' }

      reacts[state] || 'hourglass'
    end

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end
  end
end

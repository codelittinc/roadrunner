# frozen_string_literal: true

module Flows
  class CheckRunFlow < BaseSourceControlFlow
    def execute
      branch = Branch.where(name: branch_name, repository: repository).first_or_create!(pull_request: pull_request)
      CheckRun.create(commit_sha: commit_sha, state: state, branch: branch)

      return unless pull_request

      if state == CheckRun::FAILURE_STATE
        notify_ci_failure_message = Messages::PullRequestBuilder.notify_ci_failure(pull_request)
        if slack_username
          Clients::Slack::DirectMessage.new(customer).send(
            notify_ci_failure_message,
            slack_username
          )
        end
      end

      pull_request&.update(ci_state: state)

      Clients::Slack::Reactji.new(customer).send(reaction, channel, message.ts)
    end

    def flow?
      return false unless check_run
      return false if branch_name.to_s.empty?

      commit_sha && (state == CheckRun::FAILURE_STATE || state == CheckRun::SUCCESS_STATE || state == CheckRun::PENDING_STATE)
    end

    private

    def reaction
      reacts = { 'success' => 'white_check_mark',
                 'failure' => 'rotating_light' }

      reacts[state] || 'hourglass'
    end
  end
end

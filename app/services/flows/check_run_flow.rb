# frozen_string_literal: true

module Flows
  class CheckRunFlow < BaseFlow
    def execute
      if check_run
        check_run.update(state: state)
      else
        CheckRun.create(state: state, commit_sha: commit_sha)
      end

      if state == CheckRun::FAILURE_STATE
        notify_ci_failure_message = Messages::Builder.notify_ci_failure(pull_request)
        Clients::Slack::DirectMessage.new.send(
          notify_ci_failure_message,
          pull_request.user.slack
        )
      end

      pull_request&.update(ci_state: state)

      Clients::Slack::Reactji.new.send(reaction, channel, message.ts)
    end

    def flow?
      return false unless branches&.length&.positive?
      return false unless pull_request
      return false unless message

      commit && (state == CheckRun::SUCCESS_STATE || state == CheckRun::FAILURE_STATE || state == CheckRun::PENDING_STATE)
    end

    private

    def check_run
      @check_run ||= CheckRun.find_by(commit_sha: commit_sha)
    end

    def repository
      @repository ||= Repository.where(name: @params.dig(:repository, :name)).last
    end

    def pull_request
      @pull_request ||= PullRequest.where(repository: repository, head: branches[0][:name], state: 'open').last
    end

    def message
      @message = pull_request.slack_message
    end

    def state
      @state ||= @params[:state]
    end

    def branches
      @branches ||= @params[:branches]
    end

    def commit
      @commit ||= @params[:commit]
    end

    def commit_sha
      @commit_sha ||= @params[:sha]
    end

    def reaction
      reacts = { 'success' => 'white_check_mark',
                 'failure' => 'rotating_light',
                 'pending' => 'hourglass' }

      reacts[state]
    end

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end
  end
end

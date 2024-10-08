# frozen_string_literal: true

module Flows
  module Repositories
    module PullRequest
      module Check
        class Flow < BaseSourceControlFlow
          delegate :check_run, :branch_name, :commit_sha, :conclusion, to: :parser

          def execute
            # Necessary to avoid racing condition errors in repositories that have many check runs at the same time
            begin
              branch = Branch.where(name: branch_name, repository:).first_or_create!(pull_request:)
              CheckRun.create(commit_sha:, state:, branch:)
            rescue StandardError => e
              throw e
            end

            return unless pull_request

            if state == CheckRun::FAILURE_STATE
              notify_ci_failure_message = Messages::PullRequestBuilder.notify_ci_failure(pull_request)
              if slack_username
                Clients::Notifications::Direct.new(customer).send(
                  notify_ci_failure_message,
                  slack_username
                )
              end
            end

            pull_request&.update(ci_state: state)

            Clients::Notifications::Reactji.new(customer).send(reaction, channel, message.ts) if message&.ts
          end

          def can_execute?
            return false unless check_run
            return false if branch_name.to_s.empty?
            return false unless repository

            commit_sha && (state == CheckRun::FAILURE_STATE || state == CheckRun::SUCCESS_STATE || state == CheckRun::PENDING_STATE)
          end

          private

          def pull_request
            @pull_request ||= ::PullRequest.find_by(repository:, head: branch_name, state: 'open')
          end

          def message
            @message = pull_request.slack_message
          end

          def state
            CheckRun::SUPPORTED_STATES.find { |i| i == conclusion } || CheckRun::PENDING_STATE
          end

          def reaction
            reacts = { 'success' => 'white_check_mark',
                       'failure' => 'rotating_light' }

            reacts[state] || 'hourglass'
          end
        end
      end
    end
  end
end

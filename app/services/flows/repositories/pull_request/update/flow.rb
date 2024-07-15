# frozen_string_literal: true

module Flows
  module Repositories
    module PullRequest
      module Update
        class Flow < BaseSourceControlFlow
          def execute
            is_currently_draft = pull_request.draft
            pull_request.update(draft: parser.draft)
            pull_request.notify_of_creation!(channel, pull_request.branch, customer, reaction) if is_currently_draft
          end

          def can_execute?
            return false if pull_request.nil?
            return false unless parser.update_pull_request_flow?

            true
          end

          private

          def checkrun
            @checkrun ||= CheckRun.where(branch: pull_request.branch).last
          end

          def reaction
            reacts = { 'success' => 'white_check_mark',
                       'failure' => 'rotating_light',
                       'pending' => 'hourglass' }

            reacts[checkrun&.state] || 'hourglass'
          end
        end
      end
    end
  end
end

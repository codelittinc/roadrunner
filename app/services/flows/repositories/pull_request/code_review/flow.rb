# frozen_string_literal: true

module Flows
  module Repositories
    module PullRequest
      module CodeReview
        class Flow < BaseSourceControlFlow
          def execute
            return if same_review?

            PullRequestReview.create!(
              pull_request:,
              username: parser.user_identifier,
              state: parser.review_state,
              backstage_user_id: user&.id
            )

            send_message!
          end

          def can_execute?
            return false unless parser.review_comment
            return false unless pull_request
            return false unless slack_message

            true
          end

          private

          def same_review?
            PullRequestReview.where(
              username: parser.user_identifier,
              state: parser.review_state,
              backstage_user_id: user&.id
            )
                             .exists?(['created_at >= ?', 5.minutes.ago])
          end

          def user
            @user ||= Clients::Backstage::User.new.list(parser.user_identifier).first
          end

          def slack_message
            @slack_message = pull_request.slack_message
          end

          def send_message!
            slack_ts = slack_message.ts

            if parser.review_state == PullRequestReview::REVIEW_STATE_CHANGES_REQUESTED
              message = Messages::PullRequestBuilder.notify_changes_request
              Clients::Notifications::Channel.new(customer).send(message, channel, slack_ts)
            elsif parser.review_comment != ''
              message = Messages::PullRequestBuilder.notify_new_message
              Clients::Notifications::Channel.new(customer).send(message, channel, slack_ts)
            end
          end
        end
      end
    end
  end
end

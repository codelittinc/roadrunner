# frozen_string_literal: true

module Flows
  module Repositories
    module PullRequest
      module CodeReview
        class GithubParser < Parsers::BaseParser
          attr_reader :review_comment,
                      :review_state,
                      :repository_name,
                      :owner,
                      :source_control_id,
                      :mention_regex,
                      :user_identifier

          def can_parse?
            (@json[:comment] || @json.dig(:review, :body)) &&
              (@json[:action] == 'submitted' || @json[:action] == 'created')
          end

          def parse!
            @repository_name = @json.dig(:repository, :name)
            @owner = @json.dig(:pull_request, :head, :repo, :owner, :login)
            @source_control_id = @json.dig(:pull_request, :number)
            @mention_regex = /@([a-zA-Z0-9]+)/

            @review_comment = @json.dig(:comment, :body) || @json.dig(:review, :body)
            @review_state = @json.dig(:review, :state)
            @user_identifier = @json.dig(:review, :user, :login)
          end
        end
      end
    end
  end
end

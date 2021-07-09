# frozen_string_literal: true

module Parsers
  class AzurePullRequestReviewParser < BaseParser
    attr_reader :review_comment,
                :review_author,
                :repository_name,
                :owner,
                :source_control_id,
                :mention_regex

    def can_parse?
      @json[:eventType] == 'ms.vss-code.git-pullrequest-comment-event'
    end

    def new_review_submission_flow?
      true
    end

    def parse!
      @repository_name = @json.dig(:resource, :pullRequest, :repository, :name)
      @owner = @json.dig(:resource, :pullRequest, :repository, :project, :name)
      @source_control_id = @json.dig(:resource, :pullRequest, :pullRequestId)
      @mention_regex = /<([\da-zA-Z-]+)>/

      @review_comment = @json.dig(:resource, :comment, :content)
      @review_author = @review&.dig(:author, :uniqueName)
    end
  end
end

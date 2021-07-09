# frozen_string_literal: true

module Parsers
  class AzurePullRequestDirectCommentParser < BaseParser
    attr_reader :direct_comment_body,
                :repository_name,
                :owner,
                :source_control_id,
                :mention_regex

    def can_parse?
      @json[:eventType] == 'ms.vss-code.git-pullrequest-comment-event'
    end

    def parse!
      @direct_comment_body = @json.dig(:resource, :comment, :content)
      @repository_name = @json.dig(:resource, :pullRequest, :repository, :name)
      @owner = @json.dig(:resource, :pullRequest, :repository, :project, :name)
      @source_control_id = @json.dig(:resource, :pullRequest, :pullRequestId)
      @mention_regex = /<([\da-zA-Z-]+)>/
    end
  end
end

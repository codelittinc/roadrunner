module Parsers
  class GithubPullRequestDirectCommentParser < BaseParser
    attr_reader :direct_comment_body,
                :repository_name,
                :owner,
                :source_control_id,
                :mention_regex

    def can_parse?
      @json[:comment] && @json[:action] == 'created'
    end

    def parse!
      @direct_comment_body = @json[:comment][:body]
      @repository_name = @json.dig(:repository, :name)
      @owner = @json.dig(:pull_request, :head, :repo, :owner, :login)
      @source_control_id = @json.dig(:pull_request, :number)
      @mention_regex = /@([a-zA-Z0-9]+)/
    end
  end
end

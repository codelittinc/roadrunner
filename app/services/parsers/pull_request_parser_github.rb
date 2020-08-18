module Parsers
  class PullRequestParserGithub
    attr_reader :head, :base, :github_id, :repository_name, :title, :draft, :state, :owner, :username, :description, :merged_at, :branch_name

    def initialize(json)
      @json = json
    end

    def can_parse?
      @json && !!pull_request
    end

    def parse!
      @head = pull_request.dig(:head, :ref)
      @base = pull_request.dig(:base, :ref)
      @github_id = pull_request[:number]
      @repository_name = @json.dig(:repository, :name)
      @title = pull_request[:title]
      @draft = pull_request[:draft]
      @state = pull_request[:state]
      @owner = pull_request.dig(:head, :repo, :owner, :login)
      @username = pull_request.dig(:user, :login)
      @description = pull_request[:body]
      @merged_at = pull_request[:merged_at]
    end

    private

    def pull_request
      @json[:pull_request]
    end
  end
end

require 'ostruct'

module Parsers
  class GithubWebhookParser < BaseParser
    delegate :body, :state, to: :review, prefix: true, allow_nil: true
    attr_reader :base, :branch_name, :description, :draft, :github_id, :head, :merged_at, :owner, :repository_name, :review, :review_username, :state, :title, :username

    def initialize(json)
      @json = json
    end

    def can_parse?
      @json && !!pull_request
    end

    def parse!
      @base = pull_request.dig(:base, :ref)
      @description = pull_request[:body]
      @draft = pull_request[:draft]
      @github_id = pull_request[:number]
      @head = pull_request.dig(:head, :ref)
      @merged_at = pull_request[:merged_at]
      @owner = pull_request.dig(:head, :repo, :owner, :login)
      @repository_name = @json.dig(:repository, :name)
      @review = OpenStruct.new @json[:review]
      @review_username = review&.dig(:user, :login)
      @state = pull_request[:state]
      @title = pull_request[:title]
      @username = pull_request.dig(:user, :login)
    end

    private

    def pull_request
      @json[:pull_request]
    end
  end
end

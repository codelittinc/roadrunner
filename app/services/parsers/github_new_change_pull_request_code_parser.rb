# frozen_string_literal: true

module Parsers
  class GithubNewChangePullRequestCodeParser < BaseParser
    attr_reader :head,
                :repository_name,
                :owner,
                :source_control_id

    def can_parse?
      @json[:action] == 'synchronize'
    end

    def new_change_pull_request_code_flow?
      true
    end

    def parse!
      @repository_name = @json.dig(:repository, :name)
      @owner = @json.dig(:pull_request, :head, :repo, :owner, :login)
      @source_control_id = @json.dig(:pull_request, :number)
      @head = @json.dig(:pull_request, :head, :ref)
    end
  end
end

# frozen_string_literal: true

module Parsers
  class AzureNewChangePullRequestCodeParser < BaseParser
    attr_reader :head,
                :repository_name,
                :owner,
                :source_control_id

    def can_parse?
      @json[:eventType] == 'git.push'
    end

    def new_change_pull_request_code_flow?
      @json[:eventType] == 'git.push'
    end

    def parse!
      @repository_name = @json.dig(:resource, :repository, :name)
      @owner = @json.dig(:resource, :repository, :project, :name)
      branch = @json.dig(:resource, :refUpdates).first[:name]
      branch_name_regex = %r{refs/heads/(.*)}
      @head = branch.match?(branch_name_regex) ? branch.match(branch_name_regex)[1] : nil
    end
  end
end

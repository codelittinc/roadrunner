# frozen_string_literal: true

module Parsers
  class AzureNewChangePullRequestCodeParser < BaseAzureParser
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
      full_branch_name = @json.dig(:resource, :refUpdates).first[:name]
      @head = real_branch_name(full_branch_name)
    end
  end
end

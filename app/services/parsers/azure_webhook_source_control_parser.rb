# frozen_string_literal: true

require 'ostruct'

module Parsers
  class AzureWebhookSourceControlParser < BaseParser
    delegate :body, :state, to: :review, prefix: true, allow_nil: true
    attr_reader :base, :branch_name, :description, :draft, :azure_id, :head, :merged_at, :owner, :repository_name, :review, :review_username, :state, :title, :username

    def can_parse?
      @json[:publisherId] == 'tfs'
    end

    def parse!
      @base = resource[:targetRefName].scan(%r{/.+/(.+$)}).flatten.first
      @description = resource[:description]
      @azure_id = resource[:pullRequestId]
      @draft = resource[:isDraft]
      @head = resource[:sourceRefName].scan(%r{/.*/(.+/.+$)}).flatten.first
      @owner = resource.dig(:createdBy, :uniqueName)
      @repository_name = resource.dig(:repository, :name)
      @title = resource[:title]
      # @TODO: implement the fields below
      # @merged_at = pull_request[:merged_at]
      # @review = OpenStruct.new @json[:review]
      # @review_username = review&.dig(:user, :login)
      # @state = pull_request[:state]
    end

    def resource
      @json[:resource]
    end
  end
end

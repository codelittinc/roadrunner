# frozen_string_literal: true

require 'ostruct'
module Parsers
  class AzureCommentIssueParser < BaseParser
    attr_reader :event_type, :comment, :link, :issue_number

    def can_parse?
      @json && @json[:eventType] == 'workitem.commented'
    end

    def parse!
      @event_type = @json[:eventType]
      @comment = @json.dig(:detailedMessage, :html)
      @link = @json.dig(:resource, :_links, :html, :href)
      @issue_number = @link.match(/\d+$/)[0]
    end
  end
end

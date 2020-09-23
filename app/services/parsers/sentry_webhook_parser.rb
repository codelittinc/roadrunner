# frozen_string_literal: true

require 'ostruct'
module Parsers
  class SentryWebhookParser < BaseParser
    delegate :contexts, :id, :location, :metadata, :project, :title, :user, to: :event, prefix: true, allow_nil: true
    attr_reader :event, :issue_id, :project_name

    def can_parse?
      @json && @json[:project_name] && @json[:event]
    end

    def parse!
      @project_name = @json[:project_name]
      @event = OpenStruct.new @json[:event]
      @issue_id = @json[:id]
    end
  end
end

# frozen_string_literal: true

require 'ostruct'
module Parsers
  class SentryWebhookParser < BaseParser
    delegate :contexts, :id, :location, :metadata, :project, :title, :user, to: :event, prefix: true, allow_nil: true

    attr_reader :event, :issue_id, :project_name, :type, :custom_message, :custom_name

    def can_parse?
      @json && @json[:project_name] && @json[:event]
    end

    def parse!
      @event = OpenStruct.new @json[:event]
      _, @type = @event.tags.find { |name, _value| name == 'type' }
      @issue_id = @json[:id]
      @custom_message = @event.dig(:extra, :customMessage)
      _, @app_name = @event.tags.find { |name, _value| name == 'app' }
      _, @environment = @event.tags.find { |name, _value| name == 'environment' }
      @custom_name = "#{@app_name} #{@environment}".downcase
      @project_name = @json[:project_name]
    end
  end
end

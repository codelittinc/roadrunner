module Parsers
  class SentryWebhookParser < BaseParser
    attr_reader :title, :project_name

    def can_parse?
      @json && @json[:project_name] && @json[:event]
    end

    def parse!
      @title = @json.dig(:event, :title)
      @project_name = @json[:project_name]
    end
  end
end

module Parsers
  class SentryWebhookParser < BaseParser
    attr_reader :message, :project_name

    def can_parse?
      @json && @json[:project_name] && @json[:message]
    end

    def parse!
      @message = @json[:message]
      @project_name = @json[:project_name]
    end
  end
end

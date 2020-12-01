# frozen_string_literal: true

module Flows
  class AzureAlertsDatabaseProcessorFlow < BaseFlow
    delegate :threshold, :azure_link, :severity, to: :parser

    def execute
      Clients::Slack::ChannelMessage.new.send(message, channel)
    end

    def can_execute?
      parser.schema_id.present?
    end

    private

    def source
      @source ||= @params[:source]
    end

    def channel
      @channel ||= server.repository.slack_repository_info.feed_channel
    end

    def server
      @server ||= Server.where('link LIKE ?', "%#{source}%").first
    end

    def message
      Messages::GenericBuilder.azure_database_notification(server, threshold, azure_link, severity)
    end
  end
end

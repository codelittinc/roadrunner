# frozen_string_literal: true

module Flows
  class DirectMessageFlow < BaseFlow
    def execute
      response = Clients::Gpt::Client.new.generate(gpt_prompt)

      Clients::Notifications::Channel.new.send(
        response,
        slack_channel,
        message_timestamp
      )
    end

    def flow?
      @params[:type] == 'event_callback' &&
        %w[message app_mention].include?(@params[:event]&.dig(:type)) &&
        human_message? &&
        message.present?
    end

    private

    def gpt_prompt
      # @TODO: fix a bug when reading the attribute "value" from "ExternalResourceMetadata"
      # return message unless ExternalResourceMetadata.any?
      # content = ExternalResourceMetadata.last
      # "given the context #{content.value}. #{message}"

      message
    end

    def message_timestamp
      return nil unless mention?

      @params[:event][:ts]
    end

    def mention?
      @params[:event][:type] == 'app_mention'
    end

    def human_message?
      @params[:event][:bot_id].blank?
    end

    def message
      @message ||= @params[:event][:text]&.gsub(/<[^>]*>/, '')&.chomp&.strip
    end

    def slack_channel
      @params[:event][:channel]
    end
  end
end

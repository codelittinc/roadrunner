# frozen_string_literal: true

module Flows
  class GraylogsIncidentNotificationUpdateFlow < BaseFlow
    def execute
      can_execute?
      base_text = base_message.scan(/(^.*)\n?/).first.first.strip.gsub(':fire:', ':fire_engine:').gsub(':droplet:', ':fire_engine:')
      message = "#{base_text} - reviewed by @#{username}"

      Clients::Slack::ChannelMessage.new.update(message, channel, timestamp)
    end

    def flow?
      @params[:action] == 'user-addressing-error' && slack_message
    end

    def can_execute?
      return unless base_message.empty?

      raise 'Slack message text not found'
    end

    private

    def base_message
      slack_message&.text
    end

    def slack_message
      @slack_message ||= SlackMessage.where(ts: timestamp).first
    end

    def timestamp
      @params[:ts]
    end

    def username
      @params[:username]
    end

    def channel
      @params[:channel]
    end
  end
end

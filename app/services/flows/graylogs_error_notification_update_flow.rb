module Flows
  class GraylogsErrorNotificationUpdateFlow < BaseFlow
    def execute
      base_text = slack_message.text.scan(/(^.*)\n?/).first.first.strip.gsub(':fire:', ':fire_engine:').gsub(':droplet:', ':fire_engine:')
      message = "#{base_text} - reviewed by @#{username}"

      Clients::Slack::ChannelMessage.new.update(message, channel, timestamp)
    end

    def flow?
      @params[:action] == 'user-addressing-error' && slack_message
    end

    private

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

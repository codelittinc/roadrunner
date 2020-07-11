module Flows
  class GraylogsErrorNotificationUpdateFlow < BaseFlow
    def execute
      slack_message = SlackMessage.where(ts: timestamp).first
      return unless slack_message

      base_text = slack_message.text.scan(/(^.*)\n/).first.first.strip.gsub(':fire:', ':fire_engine:').gsub(':droplet:', ':fire_engine:')
      message = "#{base_text} - reviewed by @#{username}"

      Clients::Slack::ChannelMessage.new.update(message, channel, timestamp)
    end

    def isFlow?
      action = @params[:action]
      action == 'user-addressing-error'
    end

    private

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

# frozen_string_literal: true

module Flows
  class HelpSummaryFlow < BaseFlow
    def execute
      docs_link = 'https://bit.ly/33oZSkt'
      message = "Please check our documentation here #{docs_link}"

      Clients::Slack::DirectMessage.new.send(message, user_name)
    end

    def flow?
      text == 'help'
    end

    private

    def user_name
      @user_name = @params[:user_name]
    end

    def repositories
      @repositories ||= Repository.where(slack_repository_info: slack_configs)
    end

    def slack_configs
      @slack_configs ||= SlackRepositoryInfo.where(deploy_channel: channel_name)
    end

    def channel_name
      @channel_name ||= @params[:channel_name]
    end

    def text
      @text ||= @params[:text]
    end
  end
end

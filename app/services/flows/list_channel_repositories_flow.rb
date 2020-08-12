module Flows
  class ListChannelRepositoriesFlow < BaseFlow
    def execute
      message = Messages::Builder.list_repositories(channel_name, repositories)
      Clients::Slack::DirectMessage.new.send(
        message,
        user_name
      )
    end

    def flow?
      text == 'list repositories'
    end

    private

    def text
      @text ||= @params[:text]
    end

    def channel_name
      @channel_name ||= @params[:channel_name]
    end

    def user_name
      @user_name ||= @params[:user_name]
    end

    def repositories
      SlackRepositoryInfo.where(deploy_channel: channel_name).map(&:repository)
    end
  end
end

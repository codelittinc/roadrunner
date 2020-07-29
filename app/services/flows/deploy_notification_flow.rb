module Flows
  class DeployNotificationFlow < BaseFlow
    def execute
      Clients::Slack::ChannelMessage.new.send(
        "The deploy of the project *#{repository.name}* to *#{environment}* was finished with success!",
        channel
      )
    end

    def flow?
      @params[:deploy_type] == 'deploy-notification'
    end

    private

    def host
      @params[:host]
    end

    def channel
      @channel ||= repository.slack_repository_info.deploy_channel
    end

    def repository
      @repository ||= Repository.where(alias: host).first || Server.where('link LIKE ?', "%#{host}%").first.repository
    end

    def environment
      @params[:env].upcase
    end
  end
end

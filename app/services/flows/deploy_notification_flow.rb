# frozen_string_literal: true

module Flows
  class DeployNotificationFlow < BaseFlow
    def execute
      Clients::Slack::ChannelMessage.new.send(
        "The deploy of *#{repository.name}* to *#{[environment, deploy_type].reject(&:nil?).join(' - ')}* was finished with the status: #{status.capitalize}!",
        channel
      )
    end

    def flow?
      @params[:deploy_type] == 'deploy-notification' && environment.downcase != Application::DEV
    end

    private

    def source
      @params[:host]
    end

    def channel
      @channel ||= repository.slack_repository_info.deploy_channel
    end

    def repository
      @repository ||= Application.by_external_identifier(source)&.repository
    end

    def environment
      @params[:env].upcase
    end

    def status
      @status ||= @params[:status] || 'success'
    end

    def deploy_type
      @deploy_type ||= @params[:type]&.upcase
    end
  end
end

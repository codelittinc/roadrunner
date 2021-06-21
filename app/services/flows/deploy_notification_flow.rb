# frozen_string_literal: true

module Flows
  class DeployNotificationFlow < BaseFlow
    def execute
      update_release_deploy_status!

      Clients::Slack::ChannelMessage.new(client).send(
        "The deploy of *#{repository.name}* to *#{[environment, deploy_type].reject(&:nil?).join(' - ')}* was finished with the status: #{status.capitalize}!",
        channel
      )
    end

    def flow?
      @params[:deploy_type] == 'deploy-notification' && environment.downcase != Application::DEV
    end

    private

    def update_release_deploy_status!
      latest_release&.update(deploy_status: status)
    end

    def source
      @params[:host]
    end

    def channel
      @channel ||= repository.slack_repository_info.deploy_channel
    end

    def repository
      @repository ||= application.repository
    end

    def client
      repository.project.client
    end

    def latest_release
      @latest_release ||= application.releases.last
    end

    def application
      @application ||= Application.by_external_identifier(source)
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

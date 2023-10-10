# frozen_string_literal: true

module Flows
  class AppcenterDistributeNotificationFlow < BaseFlow
    delegate :environment, :source, :platform, :status, :install_link, :version, :build, to: :parser

    def execute
      release = "#{version}(#{build})"
      Clients::Notifications::Channel.new(customer).send(
        "Distribution of *#{repository.name}* to *#{[environment,
                                                     platform].compact.join(' - ')}* was finished with #{status.capitalize}, version: <#{install_link}|#{release}>",
        channel
      )
    end

    def can_execute?
      @params[:deploy_type] == 'appcenter-distribute-notification' &&
        environment.downcase != Application::DEV &&
        application
    end

    private

    def channel
      @channel ||= repository.slack_repository_info.deploy_channel
    end

    def repository
      @repository ||= application.repository
    end

    def customer
      repository.mesh_project.customer
    end

    def application
      @application ||= Application.by_external_identifier(source)
    end
  end
end

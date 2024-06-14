# frozen_string_literal: true

module Flows
  module Notifications
    module Deploy
      class Flow < BaseFlow
        delegate :environment, :source, :deploy_type, :status, to: :parser

        def execute
          update_release_deploy_status!
          message = custom_message? ? parser.custom_message : default_message

          Clients::Notifications::Channel.new(customer).send(message,
                                                             channel)
        end

        def can_execute?
          @params[:deploy_type] == 'deploy-notification' &&
            environment.downcase != Application::DEV &&
            application
        end

        private

        def custom_message?
          !!parser.custom_message
        end

        def default_message
          "The deploy of *#{repository.name}* to *#{[environment,
                                                     deploy_type].compact.join(' - ')}* was finished with the status: #{status.capitalize}!"
        end

        def update_release_deploy_status!
          latest_release&.update(deploy_status: status)
        end

        def channel
          @channel ||= repository.slack_repository_info.deploy_channel
        end

        def repository
          @repository ||= application.repository
        end

        def customer
          repository.mesh_project.customer
        end

        def latest_release
          @latest_release ||= application.releases.last
        end

        def application
          @application ||= Application.by_external_identifier(source)
        end
      end
    end
  end
end

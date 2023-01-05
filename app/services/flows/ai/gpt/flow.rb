# frozen_string_literal: true

module Flows
  module Ai
    module Gpt
      class Flow < BaseFlow
        delegate :user_name, :prompt, :text, to: :parser

        def execute
          message = Clients::Gpt::Client.new.generate(prompt)

          File.write('tmp/prompt.txt', message)
          Clients::Notifications::Direct.new.send(message, user_name)
        end

        def can_execute?
          text&.split&.first == 'ask'
        end

        private

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
          repository.project.customer
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

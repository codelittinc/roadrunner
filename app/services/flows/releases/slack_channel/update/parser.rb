# frozen_string_literal: true

module Flows
  module Releases
    module SlackChannel
      module Update
        class Parser < Parsers::BaseParser
          attr_reader :channel_name, :environment, :customer, :release_message, :channels_repositories

          UPDATE_ACTION = 'update'

          def can_parse?
            return false if @json[:text].nil? || @json[:text].blank?
            return false unless @json[:text].split.second == 'all'
            return false unless @json[:text].split.first == UPDATE_ACTION

            slack_configs = SlackRepositoryInfo.where(deploy_channel: @json[:channel_name])
            return false unless slack_configs
            return false unless Versioning.valid_env? @json[:text].split.last

            @json[:text].split.size == 3
          end

          def parse!
            @channel_name = @json[:channel_name]
            @channel_id = @json[:channel_id]
            @environment = @json[:text].split.last
            @slack_configs = SlackRepositoryInfo.by_deploy_channel(@channel_name, @channel_id)
            @channels_repositories = Repository.where(slack_repository_info: @slack_configs)
            @customer = @channels_repositories.first.project.customer
            @release_message = Messages::ReleaseBuilder.notify_release_action(UPDATE_ACTION, @environment, @json[:user_name], @channels_repositories.map(&:name).join(', '))
          end
        end
      end
    end
  end
end

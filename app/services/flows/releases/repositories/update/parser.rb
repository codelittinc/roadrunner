# frozen_string_literal: true

module Flows
  module Releases
    module Repositories
      module Update
        class Parser < Parsers::BaseParser
          attr_reader :text, :words, :channel_name, :user_name, :action, :repository_name,
                      :environment, :slack_config, :repository, :customer, :release_message

          RELEASE_ACTION = 'update'

          def can_parse?
            return false if @json[:text].nil? || @json[:text].blank?
            return false unless @json[:text].split.first == 'update'

            @slack_config = SlackRepositoryInfo.where(deploy_channel: @json[:channel_name]).first
            return false unless @slack_config
            return false unless Versioning.valid_env? @json[:text].split.last
            return false if SlackRepositoryInfo.where(deploy_channel: @json[:channel_name]).count == 1
            return false if @json[:text].split.size != 3

            @repository = Repository.where(name: @json[:text].split.second).first
            @repository&.deploy_type == Repository::TAG_DEPLOY_TYPE
          end

          def parse!
            @channel_name = @json[:channel_name]
            @slack_config = SlackRepositoryInfo.where(deploy_channel: @channel_name).first
            @text = @json[:text]
            @words = @text.split
            @user_name = @json[:user_name]
            @action = @words.first
            @repository_name = @words.second
            @environment = @words.last
            @customer = @repository.project.customer
            @repository = Repository.where(name: @repository_name).first
            @release_message = Messages::ReleaseBuilder.notify_release_action(RELEASE_ACTION, @environment, @user_name, @repository_name)
          end
        end
      end
    end
  end
end

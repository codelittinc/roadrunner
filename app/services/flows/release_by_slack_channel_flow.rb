# frozen_string_literal: true

module Flows
  class ReleaseBySlackChannelFlow < BaseFlow
    QA_ENVIRONMENT = 'qa'
    PRODUCTION_ENVIRONMENT = 'prod'
    UPDATE_ACTION = 'update'

    def execute
      Clients::Slack::ChannelMessage.new(client).send(release_message, channel_name)

      if environment == QA_ENVIRONMENT
        call_qa_release
      else
        call_prod_release
      end
    end

    def flow?
      return false if text.nil? || text.blank?
      return false unless contains_tag_all?
      return false unless action == UPDATE_ACTION

      return false unless slack_configs
      return false unless environment == QA_ENVIRONMENT || environment == PRODUCTION_ENVIRONMENT

      words.size == 3
    end

    private

    def text
      @text ||= @params[:text]
    end

    def words
      @words ||= text.split
    end

    def channel_name
      @channel_name ||= @params[:channel_name]
    end

    def user_name
      @user_name ||= @params[:user_name]
    end

    def action
      @action ||= words.first
    end

    def contains_tag_all?
      words.second == 'all'
    end

    def environment
      @environment ||= words.last
    end

    def slack_configs
      @slack_configs ||= SlackRepositoryInfo.where(deploy_channel: channel_name)
    end

    def release_message
      @release_message ||= Messages::ReleaseBuilder.notify_release_action(UPDATE_ACTION, environment, user_name, channels_repositories.map(&:name).join(', '))
    end

    def channels_repositories
      @channels_repositories ||= Repository.where(slack_repository_info: slack_configs)
    end

    def client
      channels_repositories.first.project.client
    end

    def call_qa_release
      channels_repositories.each do |repository|
        next if repository.deploy_type != Repository::TAG_DEPLOY_TYPE

        current_releases = source_control_client.new(repository).list_releases
        Flows::SubFlows::ReleaseCandidateFlow.new(channel_name, current_releases, repository).execute
      end
    end

    def call_prod_release
      channels_repositories.each do |repository|
        next if repository.deploy_type != Repository::TAG_DEPLOY_TYPE

        current_releases = source_control_client.new(repository).list_releases
        Flows::SubFlows::ReleaseStableFlow.new(channel_name, current_releases, repository).execute
      end
    end
  end
end

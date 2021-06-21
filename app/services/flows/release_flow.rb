# frozen_string_literal: true

module Flows
  class ReleaseFlow < BaseFlow
    QA_ENVIRONMENT = 'qa'
    PRODUCTION_ENVIRONMENT = 'prod'
    RELEASE_ACTION = 'update'

    def execute
      Clients::Slack::ChannelMessage.new(client).send(release_message, channel_name)

      subflow = environment == QA_ENVIRONMENT ? Flows::SubFlows::ReleaseCandidateFlow : Flows::SubFlows::ReleaseStableFlow
      @flow = subflow.new(channel_name, current_releases, repository)
      @flow.execute
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def flow?
      return false if text.nil? || text.blank?
      return false unless action == RELEASE_ACTION
      return false unless slack_config
      return false unless environment == QA_ENVIRONMENT || environment == PRODUCTION_ENVIRONMENT
      return false if SlackRepositoryInfo.where(deploy_channel: channel_name).count != 1
      return false if words.size != 2

      repository&.deploy_type == Repository::TAG_DEPLOY_TYPE
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

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

    def environment
      @environment ||= words.last
    end

    def slack_config
      @slack_config ||= SlackRepositoryInfo.where(deploy_channel: channel_name).first
    end

    def repository
      @repository ||= slack_config&.repository
    end

    def client
      repository.project.client
    end

    def release_message
      @release_message ||= Messages::ReleaseBuilder.notify_release_action(RELEASE_ACTION, environment, user_name, repository.name)
    end

    def current_releases
      @current_releases ||= source_control_client.new(repository).list_releases
    end
  end
end

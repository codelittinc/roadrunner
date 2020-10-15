# frozen_string_literal: true

# @TODO: We need to fix the release message, it is not returning the commit messages
module Flows
  class HotfixReleaseFlow < BaseFlow
    QA_ENVIRONMENT = 'qa'
    PRODUCTION_ENVIRONMENT = 'prod'
    RELEASE_ACTION = 'hotfix'

    def execute
      Clients::Slack::ChannelMessage.new.send(release_message, channel_name)

      call_subflow_by_env
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def flow?
      return false if text.nil? || text.blank?
      return false unless action == RELEASE_ACTION

      return false unless slack_config

      return false unless environment == QA_ENVIRONMENT || environment == PRODUCTION_ENVIRONMENT
      return false if SlackRepositoryInfo.where(deploy_channel: channel_name, repository: repository).count != 1
      return false if words.size != 4 && environment == QA_ENVIRONMENT
      return false if words.size != 3 && environment == PRODUCTION_ENVIRONMENT

      repository&.deploy_type == Repository::TAG_DEPLOY_TYPE
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    private

    def text
      @text ||= @params[:text]
    end

    def words
      @words ||= text.split(' ')
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

    def repository_name
      @repository_name ||= words.third
    end

    def environment
      @environment ||= words.second
    end

    def branch_name
      @branch_name ||= environment == QA_ENVIRONMENT ? words.last : ''
    end

    def slack_config
      @slack_config ||= SlackRepositoryInfo.where(deploy_channel: channel_name, repository: repository).first
    end

    def repository
      @repository ||= Repository.where(name: repository_name).first
    end

    def release_message
      @release_message ||= Messages::ReleaseBuilder.notify_release_action(RELEASE_ACTION, environment, user_name, repository.name)
    end

    def current_releases
      @current_releases ||= Clients::Github::Release.new.list(repository.full_name)
    end

    def call_subflow_by_env
      if environment == QA_ENVIRONMENT
        Flows::SubFlows::HotfixReleaseCandidateFlow.new(channel_name, current_releases, repository, branch_name).execute
      else
        Flows::SubFlows::HotfixReleaseStableFlow.new(channel_name, current_releases, repository).execute
      end
    end
  end
end

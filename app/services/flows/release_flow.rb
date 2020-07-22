module Flows
  class ReleaseFlow < BaseFlow
    QA_ENVIRONMENT = 'qa'.freeze
    PRODUCTION_ENVIRONMENT = 'prod'.freeze

    def execute
      current_releases = Clients::Github::Release.new.list(repository.full_name)

      Flows::SubFlows::ReleaseCandidateFlow.new(channel_name, current_releases, repository).execute if environment == QA_ENVIRONMENT
      Flows::SubFlows::ReleaseStableFlow.new(channel_name, current_releases, repository).execute if environment == PRODUCTION_ENVIRONMENT
    end

    def flow?
      return false if text.nil? || text.blank?
      return false unless action == 'update'
      return false unless slack_config
      return false unless environment == QA_ENVIRONMENT || environment == PRODUCTION_ENVIRONMENT

      repository&.deploy_type == Repository::TAG_DEPLOY_TYPE
    end

    private

    def text
      @text ||= @params[:text]
    end

    def channel_name
      @channel_name ||= @params[:channel_name]
    end

    def action
      @action ||= text.split(' ').first
    end

    def environment
      @environment ||= text.split(' ')[1]
    end

    def slack_config
      @slack_config ||= SlackRepositoryInfo.where(deploy_channel: channel_name).first
    end

    def repository
      @repository ||= slack_config&.repository
    end
  end
end

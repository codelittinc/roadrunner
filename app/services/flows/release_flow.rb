module Flows
  class ReleaseFlow < BaseFlow
    def execute
      releases = Clients::Github::Release.new.list(repository.full_name)
      Flows::SubFlows::ReleaseCandidateFlow.new(channel_name, releases, repository).execute
    end

    def flow?
      return false if text.nil? || text.blank?
      return false unless action == 'update'
      return false unless slack_config
      return false unless environment == 'qa' || environment == 'prod'

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

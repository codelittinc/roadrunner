module Flows
  class ReleaseByRepositoryFlow < BaseFlow
    QA_ENVIRONMENT = 'qa'.freeze
    PRODUCTION_ENVIRONMENT = 'prod'.freeze

    def execute
      current_releases = Clients::Github::Release.new.list(repository.full_name)
      Clients::Slack::ChannelMessage.new.send("Release to *#{environment.upcase}* triggered by @#{user_name}", channel_name)

      if environment == QA_ENVIRONMENT
        Flows::SubFlows::ReleaseCandidateFlow.new(channel_name, current_releases, repository).execute
      elsif environment == PRODUCTION_ENVIRONMENT
        Flows::SubFlows::ReleaseStableFlow.new(channel_name, current_releases, repository).execute
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def flow?
      return false if text.nil? || text.blank?
      return false unless action == 'update'

      return false unless slack_config
      return false unless environment == QA_ENVIRONMENT || environment == PRODUCTION_ENVIRONMENT
      return false if SlackRepositoryInfo.where(deploy_channel: channel_name).count == 1
      return false if words.size != 3

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
      @repository_name ||= words.second
    end

    def environment
      @environment ||= words.last
    end

    def slack_config
      @slack_config ||= SlackRepositoryInfo.where(deploy_channel: channel_name).first
    end

    def repository
      @repository ||= Repository.where(name: repository_name).first
    end
  end
end

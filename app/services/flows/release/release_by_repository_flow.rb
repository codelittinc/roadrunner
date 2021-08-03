# frozen_string_literal: true

module Flows
  module Release
    class ReleaseByRepositoryFlow < BaseFlow
      QA_ENVIRONMENT = 'qa'
      PRODUCTION_ENVIRONMENT = 'prod'
      RELEASE_ACTION = 'update'

      def execute
        current_releases = source_control_client.new(repository).list_releases
        Clients::Slack::ChannelMessage.new(customer).send(release_message, channel_name)

        case environment
        when QA_ENVIRONMENT
          Flows::Release::SubFlows::ReleaseCandidateFlow.new(channel_name, current_releases, repository).execute
        when PRODUCTION_ENVIRONMENT
          Flows::Release::SubFlows::ReleaseStableFlow.new(channel_name, current_releases, repository).execute
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

      def customer
        repository.project.customer
      end

      def release_message
        @release_message ||= Messages::ReleaseBuilder.notify_release_action(RELEASE_ACTION, environment, user_name,
                                                                            repository_name)
      end
    end
  end
end

# frozen_string_literal: true

# @TODO: We need to fix the release message, it is not returning the commit messages
module Flows
  class HotfixReleaseFlow < BaseFlow
    RELEASE_ACTION = 'hotfix'

    def execute
      Clients::Notifications::Channel.new(customer).send(release_message, channel_name)

      call_subflow_by_env
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def flow?
      return false if text.nil? || text.blank?
      return false unless action == RELEASE_ACTION

      return false unless slack_config

      return false unless Versioning.valid_env? environment
      return false if SlackRepositoryInfo.where(deploy_channel: channel_name, repository:).count != 1
      return false if words.size != 4 && Versioning.release_candidate_env?(environment)
      return false if words.size != 3 && Versioning.release_stable_env?(environment)

      repository&.deploy_type == Repository::TAG_DEPLOY_TYPE
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    private

    def call_subflow_by_env
      if Versioning.release_candidate_env? environment
        Flows::SubFlows::HotfixReleaseCandidateFlow.new(channel_name, current_releases, repository, branch_name,
                                                        environment).execute
      elsif Versioning.release_stable_env? environment
        Flows::SubFlows::HotfixReleaseStableFlow.new(channel_name, current_releases, repository, environment).execute
      end
    end

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
      @repository_name ||= words.third
    end

    def environment
      @environment ||= words.second
    end

    def branch_name
      @branch_name ||= Versioning.release_candidate_env?(environment) ? words.last : ''
    end

    def slack_config
      @slack_config ||= SlackRepositoryInfo.where(deploy_channel: channel_name, repository:).first
    end

    def repository
      @repository ||= Repository.where(name: repository_name).first
    end

    def customer
      repository.project.customer
    end

    def release_message
      @release_message ||= Messages::ReleaseBuilder.notify_release_action(RELEASE_ACTION, environment, user_name,
                                                                          repository.name)
    end

    def current_releases
      @current_releases ||= source_control_client.new(repository).list_releases
    end
  end
end

# frozen_string_literal: true

module Flows
  module Releases
    module Repositories
      module Update
        class Flow < BaseFlow
          delegate :repository, :channel_name, :environment, :customer, :release_message, to: :parser

          def execute
            current_releases = source_control_client.new(repository).list_releases

            Clients::Notifications::Channel.new(customer).send(release_message, channel_name)

            if Versioning.release_candidate_env? environment
              Flows::SubFlows::ReleaseCandidateFlow.new(channel_name, current_releases, repository, environment).execute
            elsif Versioning.release_stable_env? environment
              Flows::SubFlows::ReleaseStableFlow.new(channel_name, current_releases, repository, environment).execute
            end
          end

          def can_execute?
            channel_name = @params[:channel_name]
            channel_id = @params[:channel_id]
            slack_configs = SlackRepositoryInfo.by_deploy_channel(channel_name, channel_id)

            return false if @params[:text].nil? || @params[:text].blank?
            return false unless @params[:text].split.first == 'update'

            slack_config = slack_configs.first
            return false unless slack_config
            return false unless Versioning.valid_env? @params[:text].split.last
            return false if slack_configs.count == 1
            return false if @params[:text].split.size != 3

            repository = Repository.by_name(@params[:text].split.second).first
            repository&.deploy_type == Repository::TAG_DEPLOY_TYPE
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Flows
  module Releases
    module SlackChannel
      module Update
        class Flow < BaseFlow
          delegate :channel_name, :environment, :customer, :release_message, :channels_repositories, to: :parser

          UPDATE_ACTION = 'update'

          def execute
            Clients::Notifications::Channel.new(customer).send(release_message, channel_name)

            if Versioning.release_candidate_env? environment
              call_qa_release
            elsif Versioning.release_stable_env? environment
              call_prod_release
            end
          end

          def can_execute?
            return false if @params[:text].nil? || @params[:text].blank?
            return false unless @params[:text].split.second == 'all'
            return false unless @params[:text].split.first == UPDATE_ACTION

            slack_configs = SlackRepositoryInfo.where(deploy_channel: @params[:channel_name])
            return false unless slack_configs
            return false unless Versioning.valid_env? @params[:text].split.last

            @params[:text].split.size == 3
          end

          private

          def call_qa_release
            channels_repositories.each do |repository|
              next if repository.deploy_type != Repository::TAG_DEPLOY_TYPE

              current_releases = source_control_client.new(repository).list_releases
              Flows::SubFlows::ReleaseCandidateFlow.new(channel_name, current_releases, repository, environment).execute
            end
          end

          def call_prod_release
            channels_repositories.each do |repository|
              next if repository.deploy_type != Repository::TAG_DEPLOY_TYPE

              current_releases = source_control_client.new(repository).list_releases
              Flows::SubFlows::ReleaseStableFlow.new(channel_name, current_releases, repository, environment).execute
            end
          end
        end
      end
    end
  end
end

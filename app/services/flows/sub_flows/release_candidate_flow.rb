# frozen_string_literal: true

module Flows
  module SubFlows
    class ReleaseCandidateFlow < BaseReleaseSubFlow
      DEFAULT_TAG_NAME = 'rc.1.v0.0.0'
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./
      QA_ENVIRONMENT = 'qa'

      def initialize(channel_name, releases, repository)
        super(channel_name, releases, repository)
        @environment = QA_ENVIRONMENT
      end

      def execute
        channel = @repository.slack_repository_info.deploy_channel

        if release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        create_release!('master', true)

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
        update_application_version!
      end

      private

      def slack_message
        Messages::ReleaseBuilder.branch_compare_message(release_commits, 'slack', @repository.name)
      end

      def github_message
        Messages::ReleaseBuilder.branch_compare_message(release_commits, 'github', @repository.name)
      end

      def github_release_commits
        if @releases.empty?
          Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
        else
          Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_tag_name, 'master')
        end
      end

      def version_resolver
        tag_names = @releases.map(&:tag_name)
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(QA_ENVIRONMENT, tag_names, 'update')
      end
    end
  end
end

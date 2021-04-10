# frozen_string_literal: true

module Flows
  module SubFlows
    class HotfixReleaseStableFlow < BaseReleaseSubFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      PROD_ENVIRONMENT = 'prod'

      attr_reader :channel_name, :releases, :repository

      def initialize(channel_name, releases, repository)
        super(channel_name, releases, repository)
        @environment = PROD_ENVIRONMENT
      end

      def execute
        return unless version_resolver.hotfix_release_is_after_stable?

        if release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        create_release!(release_commits.last.sha, false)

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)

        update_application_version!
      end

      private

      def version_resolver
        tag_names = @releases.map(&:tag_name)
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(PROD_ENVIRONMENT, tag_names, 'hotfix')
      end

      def slack_message
        @slack_message = Messages::ReleaseBuilder.branch_compare_message_hotfix(release_commits, 'slack', @repository.name)
      end

      def github_message
        @github_message = Messages::ReleaseBuilder.branch_compare_message_hotfix(release_commits, 'github', @repository.name)
      end

      def channel
        @channel ||= @repository.slack_repository_info.deploy_channel
      end

      def github_release_commits
        if version_resolver.latest_tag_name.nil?
          Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
        else
          Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_stable_release, version_resolver.latest_tag_name)
        end
      end
    end
  end
end

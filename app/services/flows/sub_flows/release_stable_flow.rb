# frozen_string_literal: true

module Flows
  module SubFlows
    class ReleaseStableFlow < BaseReleaseSubFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      PROD_ENVIRONMENT = 'prod'

      def initialize(channel_name, releases, repository)
        super(channel_name, releases, repository)
        @environment = PROD_ENVIRONMENT
      end

      def execute
        channel = @repository.slack_repository_info.deploy_channel

        if release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        version = version_resolver.next_version

        Clients::Github::Release.new.create(
          @repository.full_name,
          version,
          release_commits.first.sha,
          github_message,
          false
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
        update_application_version!(version)
      end

      private

      def update_application_version!(version)
        app = @repository.application_by_environment(PROD_ENVIRONMENT)
        app.update(version: version)
      end

      def github_release_commits
        first_stable_release = version_resolver.latest_normal_stable_release.nil? || version_resolver.latest_normal_stable_release == 'master'

        if first_stable_release
          Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
        else
          Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_normal_stable_release, version_resolver.latest_tag_name)
        end
      end

      def version_resolver
        tag_names = @releases.map(&:tag_name)
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(PROD_ENVIRONMENT, tag_names, 'update')
      end

      def slack_message
        @slack_message ||= Messages::ReleaseBuilder.branch_compare_message(release_commits, 'slack', @repository.name)
      end

      def github_message
        @github_message ||= Messages::ReleaseBuilder.branch_compare_message(release_commits, 'github', @repository.name)
      end
    end
  end
end

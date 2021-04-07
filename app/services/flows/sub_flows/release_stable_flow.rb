# frozen_string_literal: true

module Flows
  module SubFlows
    class ReleaseStableFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      PROD_ENVIRONMENT = 'prod'

      def initialize(channel_name, releases, repository)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
      end

      def execute
        tag_names = @releases.map(&:tag_name)

        version_resolver = Versioning::ReleaseVersionResolver.new(PROD_ENVIRONMENT, tag_names, 'update')

        new_version_commits = fetch_commits(version_resolver)

        channel = @repository.slack_repository_info.deploy_channel

        if new_version_commits.empty?
          commits_message = Messages::ReleaseBuilder.notify_no_commits_changes(PROD_ENVIRONMENT, @repository.name)
          Clients::Slack::ChannelMessage.new.send(commits_message, channel)
          return
        end

        db_commits = CommitsMatcher.new(new_version_commits).commits

        slack_message = Messages::ReleaseBuilder.branch_compare_message(db_commits, 'slack', @repository.name)
        github_message = Messages::ReleaseBuilder.branch_compare_message(db_commits, 'github', @repository.name)

        version = version_resolver.next_version

        Clients::Github::Release.new.create(
          @repository.full_name,
          version,
          new_version_commits.last[:sha],
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

      def fetch_commits(version_resolver)
        first_stable_release = version_resolver.latest_normal_stable_release.nil? || version_resolver.latest_normal_stable_release == 'master'

        if first_stable_release
          Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
        else
          Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_normal_stable_release, version_resolver.latest_tag_name)
        end
      end
    end
  end
end

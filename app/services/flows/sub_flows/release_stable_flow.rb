module Flows
  module SubFlows
    class ReleaseStableFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/.freeze
      PROD_ENVIRONMENT = 'prod'.freeze

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
          commits_message = Messages::Builder.notify_no_commits_changes(PROD_ENVIRONMENT)
          Clients::Slack::ChannelMessage.new.send(commits_message, channel)
          return
        end

        db_commits = new_version_commits.map do |commit|
          date = commit[:commit][:committer][:date]
          before = date - 5.minutes
          after = date + 5.minutes

          message = commit[:commit][:message]

          Commit.where(created_at: before..after, message: message).first
        end.flatten.reject(&:nil?)

        slack_message = Messages::Builder.branch_compare_message(db_commits, 'slack')
        github_message = Messages::Builder.branch_compare_message(db_commits, 'github')

        Clients::Github::Release.new.create(
          @repository.full_name,
          version_resolver.next_version,
          new_version_commits.last[:sha],
          github_message,
          false
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
      end

      private

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

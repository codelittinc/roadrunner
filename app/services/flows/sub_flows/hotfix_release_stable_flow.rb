# frozen_string_literal: true

module Flows
  module SubFlows
    class HotfixReleaseStableFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      PROD_ENVIRONMENT = 'prod'

      attr_reader :channel_name, :releases, :repository, :version_resolver

      def initialize(channel_name, releases, repository)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
      end

      def execute
        tag_names = @releases.map(&:tag_name)

        @version_resolver = Versioning::ReleaseVersionResolver.new(PROD_ENVIRONMENT, tag_names, 'hotfix')

        return unless version_resolver.hotfix_release_is_after_stable?

        if commits.empty?
          commits_message = Messages::ReleaseBuilder.notify_no_commits_changes(PROD_ENVIRONMENT, @repository.name)
          Clients::Slack::ChannelMessage.new.send(commits_message, channel)
          return
        end

        Clients::Github::Release.new.create(
          @repository.full_name,
          version_resolver.next_version,
          commits.last[:sha],
          github_message,
          false
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
      end

      private

      def db_commits
        db_commits = commits.map do |commit|
          message = commit[:commit][:message]

          Commit.where(message: message).first
        end.flatten
        db_commits.uniq { |c| c }
      end

      def slack_message
        @slack_message = Messages::ReleaseBuilder.branch_compare_message_hotfix(db_commits, 'slack', @repository.name)
      end

      def github_message
        @github_message = Messages::ReleaseBuilder.branch_compare_message_hotfix(db_commits, 'github', @repository.name)
      end

      def channel
        @channel ||= @repository.slack_repository_info.deploy_channel
      end

      def commits
        @commits ||= if version_resolver.latest_tag_name.nil?
                       Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
                     else
                       Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_stable_release, version_resolver.latest_tag_name)
                     end
      end
    end
  end
end

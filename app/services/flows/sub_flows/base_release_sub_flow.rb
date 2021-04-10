# frozen_string_literal: true

module Flows
  module SubFlows
    class BaseReleaseSubFlow
      def initialize(channel_name, releases, repository)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
      end

      def release_commits
        return @release_commits if @release_commits

        @release_commits = CommitsMatcher.new(github_release_commits).commits
      end

      def notify_no_changes_between_releases!
        channel = @repository.slack_repository_info.deploy_channel
        commits_message = Messages::ReleaseBuilder.notify_no_commits_changes(@environment, @repository.name)
        Clients::Slack::ChannelMessage.new.send(commits_message, channel)
      end

      def version
        @version ||= version_resolver.next_version
      end

      def channel
        @channel ||= @repository.slack_repository_info.deploy_channel
      end

      def update_application_version!
        app = @repository.application_by_environment(@environment)
        app&.update(version: version)
      end

      def create_release!(target, prerelease)
        Clients::Github::Release.new.create(
          @repository.full_name,
          version,
          target,
          github_message,
          prerelease
        )
      end

      def github_release_commits
        throw Error.new('Implement this method!')
      end

      def version_resolver
        throw Error.new('Implement this method!')
      end

      def slack_message
        throw Error.new('Implement this method!')
      end

      def github_message
        throw Error.new('Implement this method!')
      end
    end
  end
end

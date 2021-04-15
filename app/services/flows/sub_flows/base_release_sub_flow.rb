# frozen_string_literal: true

module Flows
  module SubFlows
    class BaseReleaseSubFlow
      def initialize(channel_name, releases, repository)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
      end

      # @TODO: Update to use the CommitsMatcher
      def release_commits
        return @commits if @commits

        @commits = []
        github_release_commits.each do |commit|
          message = commit[:commit][:message]

          c = Commit
              .where.not(id: @commits.map(&:id))
              .where(message: message).first
          @commits << c if c
        end

        @commits
      end

      def notify_no_changes_between_releases!
        channel = @repository.slack_repository_info.deploy_channel
        commits_message = Messages::ReleaseBuilder.notify_no_commits_changes(environment, @repository.name)
        Clients::Slack::ChannelMessage.new.send(commits_message, channel)
      end

      def version
        @version ||= version_resolver.next_version
      end

      def channel
        @channel ||= @repository.slack_repository_info.deploy_channel
      end

      def update_application_version!
        app = @repository.application_by_environment(environment)
        Release.create(application: app, version: version, commits: release_commits) if app
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

      def tag_names
        @tag_names ||= @releases.map(&:tag_name)
      end

      def environment
        throw Error.new('Implement this method!')
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

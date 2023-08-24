# frozen_string_literal: true

module Flows
  module SubFlows
    class BaseReleaseSubFlow
      attr_reader :environment

      def initialize(channel_name, releases, repository, environment)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
        @customer = repository.project.customer
        @environment = environment
      end

      def base_branch
        @base_branch ||= @repository.base_branch
      end

      def source_control_client
        Clients::SourceControlClient.new(@repository)
      end

      # @TODO: Update to use the CommitsMatcher
      def release_commits
        return @commits if @commits

        @commits = []
        source_control_release_commits.each do |commit|
          message = commit.message

          c = Commit
              .where.not(id: @commits.map(&:id))
              .where(message:).first
          @commits << c if c
        end

        @commits
      end

      def notify_no_changes_between_releases!
        channel = @repository.slack_repository_info.deploy_channel
        commits_message = Messages::ReleaseBuilder.notify_no_commits_changes(environment, @repository.name)
        Clients::Notifications::Channel.new(@customer).send(commits_message, channel)
      end

      def version
        @version ||= version_resolver.next_version
      end

      def channel
        @channel ||= @repository.slack_repository_info.deploy_channel
      end

      def update_application_version!
        app = @repository.application_by_environment(environment)
        Release.create(application: app, version:, commits: release_commits) if app
      end

      def create_release!(target, prerelease)
        source_control_client.create_release(
          version,
          target,
          github_message,
          prerelease
        )
      end

      def tag_names
        @tag_names ||= @releases.map(&:tag_name)
      end

      def source_control_release_commits
        throw Error.new('Implement this method!')
      end

      def version_resolver
        throw Error.new('Implement this method!')
      end

      def slack_message
        @slack_message = Messages::ReleaseBuilder.branch_compare_message(release_commits, 'slack', @repository.name)
      end

      def github_message
        @github_message = Messages::ReleaseBuilder.branch_compare_message(release_commits, 'github', @repository.name)
      end
    end
  end
end

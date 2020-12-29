# frozen_string_literal: true

module Flows
  module SubFlows
    class ReleaseCandidateFlow
      DEFAULT_TAG_NAME = 'rc.1.v0.0.0'
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./
      QA_ENVIRONMENT = 'qa'

      def initialize(channel_name, releases, repository)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
      end

      def execute
        db_commits = commits.map do |commit|
          date = commit[:commit][:committer][:date]
          before = date - 5.minutes
          after = date + 5.minutes

          message = commit[:commit][:message]

          Commit.where(created_at: before..after, message: message).first
        end.flatten

        channel = @repository.slack_repository_info.deploy_channel
        if commits.empty?
          commits_message = Messages::ReleaseBuilder.notify_no_commits_changes(QA_ENVIRONMENT, @repository.name)
          Clients::Slack::ChannelMessage.new.send(commits_message, channel)
          return
        end

        slack_message = Messages::ReleaseBuilder.branch_compare_message(db_commits, 'slack', @repository.name)
        github_message = Messages::ReleaseBuilder.branch_compare_message(db_commits, 'github', @repository.name)

        Clients::Github::Release.new.create(
          @repository.full_name,
          version_resolver.next_version,
          'master',
          github_message,
          true
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
      end

      private

      def commits
        @commits ||= if @releases.empty?
                       Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
                     else
                       Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_tag_name, 'master')
                     end
      end

      def tag_names
        @tag_names ||= @releases.map(&:tag_name)
      end

      def version_resolver
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(QA_ENVIRONMENT, tag_names, 'update')
      end
    end
  end
end

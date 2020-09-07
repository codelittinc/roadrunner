# frozen_string_literal: true

module Flows
  module SubFlows
    class HotfixReleaseCandidateFlow
      DEFAULT_TAG_NAME = 'rc.1.v0.0.0'
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/.freeze
      RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./.freeze
      QA_ENVIRONMENT = 'qa'

      attr_reader :branch, :channel_name, :releases, :repository, :version_resolver

      def initialize(channel_name, releases, repository, branch)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
        @branch = branch
      end

      def execute
        unless branch_exists
          branch_message = Messages::Builder.notify_branch_existence(branch, false)
          Clients::Slack::ChannelMessage.new.send(branch_message, channel)
          return
        end

        tag_names = @releases.map(&:tag_name)

        @version_resolver = Versioning::ReleaseVersionResolver.new(QA_ENVIRONMENT, tag_names, 'hotfix')

        if commits.empty?
          commits_message = Messages::Builder.notify_no_commits_changes(QA_ENVIRONMENT, @repository.name)
          Clients::Slack::ChannelMessage.new.send(commits_message, channel)
          return
        end

        Clients::Github::Release.new.create(
          @repository.full_name,
          version_resolver.next_version,
          branch,
          github_message,
          true
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
      end

      private

      def db_commits
        db_commits = commits.map do |commit|
          date = commit[:commit][:committer][:date]
          before = date - 5.minutes
          after = date + 5.minutes

          message = commit[:commit][:message]

          Commit.where(created_at: before..after, message: message).first
        end.flatten
        db_commits.select { |c| c }
      end

      def slack_message
        @slack_message = Messages::Builder.branch_compare_message_hotfix(db_commits, 'slack', @repository.name)
      end

      def github_message
        @github_message = Messages::Builder.branch_compare_message_hotfix(db_commits, 'github', @repository.name)
      end

      def channel
        @channel ||= @repository.slack_repository_info.deploy_channel
      end

      def branch_exists
        @branch_exists ||= Clients::Github::Branch.new.branch_exists?(@repository.full_name, branch)
      end

      def first_pre_release?
        @releases.empty?
      end

      def commits
        @commits ||= if first_pre_release?
                       Clients::Github::Branch.new.commits(@repository.full_name, branch).reverse
                     else
                       Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_tag_name, branch)
                     end
      end
    end
  end
end

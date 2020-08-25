module Flows
  module SubFlows
    class ReleaseCandidateFlow
      DEFAULT_TAG_NAME = 'rc.1.v0.0.0'.freeze
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/.freeze
      RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./.freeze
      QA_ENVIRONMENT = 'qa'.freeze

      def initialize(channel_name, releases, repository)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
      end

      def execute
        tag_names = @releases.map(&:tag_name)

        version_resolver = Versioning::ReleaseVersionResolver.new(QA_ENVIRONMENT, tag_names, 'update')

        commits = if @releases.empty?
                    Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
                  else
                    Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_tag_name, 'master')
                  end

        db_commits = commits.map do |commit|
          date = commit[:commit][:committer][:date]
          before = date - 5.minutes
          after = date + 5.minutes

          message = commit[:commit][:message]

          Commit.where(created_at: before..after, message: message).first
        end.flatten

        channel = @repository.slack_repository_info.deploy_channel
        if commits.empty?
          commits_message = Messages::Builder.notify_no_commits_changes(QA_ENVIRONMENT)
          Clients::Slack::ChannelMessage.new.send(commits_message, channel)
          return
        end

        slack_message = Messages::Builder.branch_compare_message(db_commits, 'slack')
        github_message = Messages::Builder.branch_compare_message(db_commits, 'github')

        Clients::Github::Release.new.create(
          @repository.full_name,
          version_resolver.next_version,
          'master',
          github_message,
          true
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
      end
    end
  end
end

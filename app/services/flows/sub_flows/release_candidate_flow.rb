module Flows
  module SubFlows
    class ReleaseCandidateFlow
      DEFAULT_TAG_NAME = 'rc.1.v0.0.0'.freeze
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/.freeze
      RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./.freeze

      def initialize(channel_name, releases, repository)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
      end

      def execute
        latest_release = @releases.first
        tag_name = latest_release[:tag_name]
        is_from_release = !tag_name.match?(/rc/)
        major, minor, patch = tag_name.scan(RELEASE_REGEX).flatten
        new_rc_version = 1

        if is_from_release
          minor = minor.to_i + 1
        else
          current_release_candidate_version = latest_release[:tag_name].scan(RELEASE_CANDIDATE_VERSION_REGEX).flatten.first.to_i
          new_rc_version = current_release_candidate_version + 1
        end

        new_version = "rc.#{new_rc_version}.v#{major}.#{minor}.#{patch}"
        commits = Clients::Github::Branch.new.compare(@repository.full_name, latest_release[:tag_name], 'master')
        db_commits = commits.map do |commit|
          date = commit[:commit][:committer][:date]
          before = date - 5.minutes
          after = date + 5.minutes

          message = commit[:commit][:message]

          Commit.where(created_at: before..after, message: message).first
        end.flatten

        channel = @repository.slack_repository_info.deploy_channel
        if commits.empty?
          Clients::Slack::ChannelMessage.new.send("Hey the *QA* environment already has all the latest changes", channel)
          return
        end

        slack_message = Messages::Builder.branch_compare_message(db_commits, 'slack')
        github_message = Messages::Builder.branch_compare_message(db_commits, 'github')

        Clients::Github::Release.new.create(
          @repository.full_name,
          new_version,
          'master',
          github_message,
          true
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
      end
    end
  end
end

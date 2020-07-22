module Flows
  module SubFlows
    class ReleaseStableFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/.freeze

      def initialize(channel_name, releases, repository)
        @channel_name = channel_name
        @releases = releases
        @repository = repository
      end

      def execute
        oldest_pre_release = @releases.first
        latest_pre_release = @releases.first

        @releases.each do |release|
          if release[:prerelease]
            oldest_pre_release = release
          else
            break
          end
        end

        major, minor, patch = latest_pre_release[:tag_name].scan(RELEASE_REGEX).flatten
        new_tag_version = "v#{major}.#{minor}.#{patch}"

        new_version_commits = Clients::Github::Branch.new.compare(
          @repository.full_name,
          oldest_pre_release[:tag_name],
          latest_pre_release[:tag_name]
        )

        db_commits = new_version_commits.map do |commit|
          date = commit[:commit][:committer][:date]
          before = date - 5.minutes
          after = date + 5.minutes

          message = commit[:commit][:message]

          Commit.where(created_at: before..after, message: message).first
        end.flatten.reject(&:nil?)

        channel = @repository.slack_repository_info.deploy_channel

        if new_version_commits.empty?
          Clients::Slack::ChannelMessage.new.send("Hey the *PROD* environment already has all the latest changes", channel)
          return
        end

        slack_message = Messages::Builder.branch_compare_message(db_commits, 'slack')
        github_message = Messages::Builder.branch_compare_message(db_commits, 'github')

        Clients::Github::Release.new.create(
          @repository.full_name,
          new_tag_version,
          new_version_commits.last[:sha],
          github_message,
          false
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
      end
    end
  end
end

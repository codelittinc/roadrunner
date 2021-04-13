# frozen_string_literal: true

module Flows
  module SubFlows
    class ReleaseStableFlow < BaseReleaseSubFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/

      def execute
        channel = @repository.slack_repository_info.deploy_channel

        if github_release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        Clients::Github::Release.new.create(
          @repository.full_name,
          version,
          github_release_commits.last[:sha],
          github_message,
          false
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)
        update_application_version!
      end

      private

      def environment
        Application::PROD
      end

      def release_commits
        github_release_commits.map do |commit|
          date = commit[:commit][:committer][:date]
          before = date - 5.minutes
          after = date + 5.minutes

          message = commit[:commit][:message]

          Commit.where(created_at: before..after, message: message).first
        end.flatten.compact
      end

      def slack_message
        @slack_message ||= Messages::ReleaseBuilder.branch_compare_message(release_commits, 'slack', @repository.name)
      end

      def github_message
        @github_message ||= Messages::ReleaseBuilder.branch_compare_message(release_commits, 'github', @repository.name)
      end

      def version_resolver
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(environment, tag_names, 'update')
      end

      def github_release_commits
        return @github_release_commits if @github_release_commits

        first_stable_release = version_resolver.latest_normal_stable_release.nil? || version_resolver.latest_normal_stable_release == 'master'

        @github_release_commits ||= if first_stable_release
                                      Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
                                    else
                                      Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_normal_stable_release, version_resolver.latest_tag_name)
                                    end
      end
    end
  end
end

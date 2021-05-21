# frozen_string_literal: true

module Flows
  module SubFlows
    class ReleaseStableFlow < BaseReleaseSubFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/

      def execute
        channel = @repository.slack_repository_info.deploy_channel

        if source_control_release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        source_control_client.create_release(
          version,
          source_control_release_commits.last.sha,
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
        source_control_release_commits.map do |commit|
          next if commit.date.nil?

          date = commit.date
          date = Date.parse(date) if date.instance_of?(String)

          before = date - 5.minutes
          after = date + 5.minutes

          message = commit.message
          Commit.where(created_at: before..after, message: message).first
        end.flatten.compact
      end

      def version_resolver
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(environment, tag_names, 'update')
      end

      def source_control_release_commits
        return @source_control_release_commits if @source_control_release_commits

        first_stable_release = version_resolver.latest_normal_stable_release.nil? || version_resolver.latest_normal_stable_release == 'master'

        @source_control_release_commits ||= if first_stable_release
                                      source_control_client.list_branch_commits('master').reverse
                                    else
                                      source_control_client.compare_commits(version_resolver.latest_normal_stable_release, version_resolver.latest_tag_name)
                                    end
      end
    end
  end
end

# frozen_string_literal: true

module Flows
  module SubFlows
    class HotfixReleaseStableFlow < BaseReleaseSubFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/

      attr_reader :channel_name, :releases

      def execute
        return unless version_resolver.hotfix_release_is_after_stable?

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

        Clients::Slack::ChannelMessage.new(@customer).send(slack_message, channel)

        update_application_version!
      end

      private

      def environment
        Application::PROD
      end

      def version_resolver
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(environment, tag_names, 'hotfix')
      end

      def source_control_release_commits
        return @source_control_release_commits if @source_control_release_commits

        @source_control_release_commits ||= if version_resolver.latest_tag_name.nil?
                                              source_control_client.list_branch_commits('master').reverse
                                            else
                                              source_control_client.compare_commits(
                                                version_resolver.latest_stable_release, version_resolver.latest_tag_name
                                              )
                                            end
      end
    end
  end
end

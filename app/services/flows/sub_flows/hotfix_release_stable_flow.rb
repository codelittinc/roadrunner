# frozen_string_literal: true

module Flows
  module SubFlows
    class HotfixReleaseStableFlow < BaseReleaseSubFlow
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/

      attr_reader :channel_name, :releases

      def execute
        return unless version_resolver.hotfix_release_is_after_stable?

        if github_release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        Clients::Github::Release.new.create(
          @repository.full_name,
          version,
          github_release_commits.last.sha,
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

      def version_resolver
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(environment, tag_names, 'hotfix')
      end

      def github_release_commits
        return @github_release_commits if @github_release_commits

        @github_release_commits ||= if version_resolver.latest_tag_name.nil?
                                      Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
                                    else
                                      Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_stable_release, version_resolver.latest_tag_name)
                                    end
      end
    end
  end
end

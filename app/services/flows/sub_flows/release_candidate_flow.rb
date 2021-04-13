# frozen_string_literal: true

module Flows
  module SubFlows
    class ReleaseCandidateFlow < BaseReleaseSubFlow
      DEFAULT_TAG_NAME = 'rc.1.v0.0.0'
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./

      def execute
        if github_release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        Clients::Github::Release.new.create(
          @repository.full_name,
          version,
          'master',
          github_message,
          true
        )

        Clients::Slack::ChannelMessage.new.send(slack_message, channel)

        update_application_version!
      end

      private

      def environment
        Application::QA
      end

      def slack_message
        @slack_message ||= Messages::ReleaseBuilder.branch_compare_message(release_commits, 'slack', @repository.name)
      end

      def github_message
        @github_message ||= Messages::ReleaseBuilder.branch_compare_message(release_commits, 'github', @repository.name)
      end

      def github_release_commits
        return @github_release_commits if @github_release_commits

        @github_release_commits ||= if @releases.empty?
                                      Clients::Github::Branch.new.commits(@repository.full_name, 'master').reverse
                                    else
                                      Clients::Github::Branch.new.compare(@repository.full_name, version_resolver.latest_tag_name, 'master')
                                    end
      end

      def version_resolver
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(environment, tag_names, 'update')
      end
    end
  end
end

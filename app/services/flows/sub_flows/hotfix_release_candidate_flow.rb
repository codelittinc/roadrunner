# frozen_string_literal: true

module Flows
  module SubFlows
    class HotfixReleaseCandidateFlow < BaseReleaseSubFlow
      DEFAULT_TAG_NAME = 'rc.1.v0.0.0'
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./

      attr_reader :branch, :channel_name, :releases

      def initialize(channel_name, releases, repository, branch, environment)
        super(channel_name, releases, repository, environment)
        @branch = branch
      end

      def execute
        unless branch_exists
          branch_message = Messages::ReleaseBuilder.notify_branch_existence(branch, false)
          Clients::Notifications::Channel.new(@customer).send(branch_message, channel)
          return
        end

        if source_control_release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        source_control_client.create_release(
          version,
          branch,
          github_message,
          true
        )

        Clients::Notifications::Channel.new(@customer).send(slack_message, channel)

        update_application_version!
      end

      private

      def branch_exists
        @branch_exists ||= source_control_client.branch_exists?(branch)
      end

      def first_pre_release?
        @releases.empty?
      end

      def version_resolver
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(environment, tag_names, 'hotfix')
      end

      def source_control_release_commits
        return @source_control_release_commits if @source_control_release_commits

        @source_control_release_commits ||= if first_pre_release?
                                              source_control_client.list_branch_commits(branch).reverse
                                            else
                                              source_control_client.compare_commits(version_resolver.latest_tag_name,
                                                                                    branch)
                                            end
      end
    end
  end
end

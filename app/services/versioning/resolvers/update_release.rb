# frozen_string_literal: true

module Versioning
  module Resolvers
    class UpdateRelease
      def initialize(environment, releases)
        @environment = environment
        @releases = Versioning::Sorter.new(filter_releases(releases)).sort
        @major, @minor, @patch = latest_tag_name&.scan(Versioning::RELEASE_REGEX)&.flatten
      end

      def next_version
        if Versioning.release_candidate_env? environment
          mount_rc_version
        elsif Versioning.release_stable_env? environment
          mount_stable_version
        end
      end

      def latest_tag_name
        releases.find { |r| Versioning.normal?(r) }
      end

      def latest_normal_stable_release
        @releases.find { |r| Versioning.stable?(r) && Versioning.normal?(r) }
      end

      private

      attr_reader :environment, :releases, :patch, :minor, :major

      def latest_qa_release
        @releases.find { |r| !Versioning.stable?(r) && Versioning.normal?(r) }
      end

      def mount_rc_version
        rc_version = (Versioning.release_candidate_version(latest_tag_name) || 0) + 1
        new_minor = minor.to_i
        new_major = major.to_i

        if Versioning.first_pre_release?(latest_tag_name)
          new_major += 1
        elsif !latest_normal_stable_release.nil? && latest_qa_release != latest_tag_name
          new_minor += 1
        end

        "rc.#{rc_version}.v#{new_major}.#{new_minor}.#{patch || 0}"
      end

      def mount_stable_version
        return if latest_qa_release.nil?

        new_major, new_minor, new_patch = latest_qa_release&.scan(Versioning::RELEASE_REGEX)&.flatten
        "v#{new_major}.#{new_minor}.#{new_patch}"
      end

      def filter_releases(releases)
        releases.select { |release| release.match?(/^(rc.\d+.)?v\d+.\d+.\d+$/) }
      end
    end
  end
end

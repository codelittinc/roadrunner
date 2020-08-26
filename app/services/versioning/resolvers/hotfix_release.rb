module Versioning
  module Resolvers
    class HotfixRelease
      def initialize(environment, releases)
        @environment = environment
        @releases = releases
        @major, @minor, @patch = latest_tag_name&.scan(Versioning::RELEASE_REGEX)&.flatten
      end

      def next_version
        case environment
        when Versioning::QA_ENVIRONMENT
          mount_qa_version
        when Versioning::PROD_ENVIRONMENT
          mount_prod_version
        end
      end

      private

      attr_reader :environment, :releases, :patch, :minor, :major

      def latest_tag_name
        @releases.find { |r| (Versioning.hotfix?(r) && Versioning.release_candidate?(r)) || Versioning.stable?(r) }
      end

      def latest_normal_stable_release
        @releases.find { |r| Versioning.stable?(r) & Versioning.normal?(r) }
      end

      def hotfix_release_is_after_stable?
        index_latest_tag_name = @releases.index(latest_tag_name)
        index_latest_normal_stable_release = @releases.index(latest_normal_stable_release)
        return false unless index_latest_tag_name || index_latest_normal_stable_release

        index_latest_tag_name < index_latest_normal_stable_release
      end

      def mount_qa_version
        return nil if Versioning.first_pre_release?(latest_tag_name)

        rc_version = (Versioning.release_candidate_version(latest_tag_name) || 0) + 1
        new_patch = patch.to_i

        if Versioning.hotfix?(latest_tag_name)
          new_patch += 1 if Versioning.stable?(latest_tag_name)
        else
          new_patch += 1
        end

        "rc.#{rc_version}.v#{major}.#{minor}.#{new_patch}"
      end

      def mount_prod_version
        return nil unless hotfix_release_is_after_stable?

        "v#{major}.#{minor}.#{patch}"
      end
    end
  end
end

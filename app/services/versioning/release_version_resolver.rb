module Versioning
  class ReleaseVersionResolver
    delegate :next_version,
             :latest_tag_name,
             :latest_normal_stable_release,
             :latest_stable_release,
             :hotfix_release_is_after_stable?, to: :resolver, allow_nil: true
    attr_reader :resolver

    ACTION_UPDATE = 'update'.freeze

    def initialize(environment, releases, action)
      @resolver = action == ACTION_UPDATE ? Versioning::Resolvers::UpdateRelease.new(environment, releases) : Versioning::Resolvers::HotfixRelease.new(environment, releases)
    end
  end
end

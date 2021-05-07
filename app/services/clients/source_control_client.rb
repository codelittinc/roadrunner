# frozen_string_literal: true

module Clients
  class SourceControlClient
    def initialize(repository)
      @repository = repository
    end

    def list_releases
      Clients::Github::Release.new.list(@repository)
    end

    def create_release(tag_name, target, body, prerelease)
      Clients::Github::Release.new.create(@repository, tag_name, target, body, prerelease)
    end
  end
end

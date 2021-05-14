# frozen_string_literal: true

module Clients
  class SourceControlClient
    def initialize(repository)
      @repository = repository
    end

    def list_releases
      client_class('Release').new.list(@repository)
    end

    def create_release(tag_name, target, body, prerelease)
      client_class('Release').new.create(@repository, tag_name, target, body, prerelease)
    end

    def branch_exists?(branch)
      client_class('Branch').new.branch_exists?(@repository, branch)
    end

    def get_pull_request(source_control_id)
      client_class('PullRequest').new.get(@repository, source_control_id)
    end

    def list_pull_request_commits(source_control_id)
      client_class('PullRequest').new.list_commits(@repository, source_control_id)
    end

    def list_branch_commits(branch)
      client_class('Branch').new.commits(@repository, branch)
    end

    def compare_commits(head, base)
      client_class('Branch').new.compare(@repository, head, base)
    end

    def delete_branch(branch)
      client_class('Branch').new.delete(@repository, branch)
    end

    def list_hooks
      client_class('Hook').new.list(@repository)
    end

    def create_hook
      client_class('Hook').new.create(@repository)
    end

    def repository
      client_class('Repository').new.get_repository(@repository)
    end

    private

    def client_class(classname)
      Object.const_get("Clients::#{@repository.source_control_type.capitalize}::#{classname}")
    end
  end
end

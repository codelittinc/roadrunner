# frozen_string_literal: true

module Clients
  class SourceControlClient
    def initialize(repository)
      @repository = repository
      @client = repository.source_control_type
    end

    # Release

    def list_releases
      @client == 'github' ? Clients::Github::Release.new.list(@repository) : Clients::Azure::Release.new.list(@repository)
    end

    def create_release(tag_name, target, body, prerelease)
      if @client == 'github'
        Clients::Github::Release.new.create(@repository, tag_name, target, body, prerelease)
      else
        Clients::Azure::Release.new.create(@repository, tag_name, target, body, prerelease)
      end
    end

    # pull request

    def get_pull_request(source_control_id)
      if @client == 'github'
        Clients::Github::PullRequest.new.get(@repository, source_control_id)
      else
        Clients::Azure::PullRequest.new.get(@repository, source_control_id)
      end
    end

    # commits

    def list_pull_request_commits(source_control_id)
      if @client == 'github'
        Clients::Github::PullRequest.new.list_commits(@repository, source_control_id)
      else
        Clients::Azure::PullRequest.new.list_commits(@repository, source_control_id)
      end
    end

    def list_branch_commits(branch)
      if @client == 'github'
        Clients::Github::Branch.new.commits(@repository, branch)
      else
        Clients::Azure::Branch.new.commits(@repository, branch)
      end
    end

    def compare_commits(head, base)
      if @client == 'github'
        Clients::Github::Branch.new.compare(@repository, head, base)
      else
        Clients::Azure::Branch.new.compare(@repository, head, base)
      end
    end

    # branch

    def branch_exists?(branch)
      if @client == 'github'
        Clients::Github::Branch.new.branch_exists?(@repository, branch)
      else
        Clients::Azure::Branch.new.branch_exists?(@repository, branch)
      end
    end

    # github hook

    def list_github_hook
      Clients::Github::Hook.new.list(@repository)
    end

    def create_github_hook(name)
      Clients::Github::Hook.new.create(@repository, name)
    end
  end
end

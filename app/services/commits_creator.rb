# frozen_string_literal: true

class CommitsCreator
  def initialize(repository, pull_request)
    @repository = repository
    @pull_request = pull_request
  end

  def create!
    commits = Clients::Github::PullRequest.new.list_commits(@repository.full_name, @pull_request.source_control_id)

    throw Error.new("No commits found for #{@repository.full_name} - #{@pull_request.source_control_id}") if commits.length.zero?

    commits.each do |commit|
      Commit.create!(
        pull_request: @pull_request,
        sha: commit.sha,
        author_name: commit.author_name,
        author_email: commit.author_email,
        message: commit.message
      )
    end
  end
end

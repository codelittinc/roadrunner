# frozen_string_literal: true

class CommitsCreator
  def initialize(repository, pull_request, pull_request_client)
    @repository = repository
    @pull_request = pull_request
    @pull_request_client = pull_request_client
  end

  def create!
    commits = @pull_request_client.new.list_commits(@repository, @pull_request.source_control_id)

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

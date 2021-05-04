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
      commit_parser = Clients::Github::Parsers::CommitParser.new(commit)
      Commit.create!(
        pull_request: @pull_request,
        sha: commit_parser.sha,
        author_name: commit_parser.author_name,
        author_email: commit_parser.author_email,
        message: commit_parser.message
      )
    end
  end
end

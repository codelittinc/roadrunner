class CommitsCreator
  def initialize(repository, pull_request)
    @repository = repository
    @pull_request = pull_request
  end

  def create!
    commits = Clients::Github::PullRequest.new.list_commits(@repository.full_name, @pull_request.github_id)
    commits.each do |commit|
      Commit.create!(
        pull_request: pull_request,
        sha: commit[:sha],
        author_name: commit[:commit][:author][:name],
        author_email: commit[:commit][:author][:email],
        message: commit[:commit][:message]
      )
    end
  end
end

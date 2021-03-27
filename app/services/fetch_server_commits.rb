class FetchServerCommits
  def self.server_commits(server_id)
    server = Server.find_by(id: server_id)
    pull_requests = server.repository.pull_requests.includes(:commits).where.not(commits: { id: nil })
    pull_requests.map {|pr| pr.commits }.flatten
  end
end

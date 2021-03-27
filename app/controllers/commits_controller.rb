# frozen_string_literal: true

class CommitsController < ApplicationController
  def index
    commits = FetchServerCommits.server_commits(params[:server_id])

    json = commits.map do |commit|
      {
        id: commit.id,
        sha: commit.sha,
        author_name: commit.author_name
      }
    end

    render json: json
  end
end

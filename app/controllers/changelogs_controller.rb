# frozen_string_literal: true

class ChangelogsController < ApplicationController
  def index
    release = Release.find(params[:release_id])
    commits = release.commits
    version = release.version
    changelog = ChangelogsService.new(commits, version).changelog
    render json: changelog
  end
end

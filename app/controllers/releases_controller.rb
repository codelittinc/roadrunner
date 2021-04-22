# frozen_string_literal: true

class ReleasesController < ApplicationController
  def show
    release = Release.find(params[:id])
    commits = release.commits
    version = release.version
    changelog = ChangelogsService.new(commits, version).changelog
    render json: changelog
  end
end

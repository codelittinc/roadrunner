# frozen_string_literal: true

class ReleasesController < ApplicationController
  def show
    release = Release.find(params[:id])
    commits = release.commits
    version = release.version
    changelog = ChangelogsService.new(commits, version).changelog
    render json: changelog
  end

  def index
    application = Application.find(params[:application_id])
    releases = application.releases
    render json: releases
  end
end

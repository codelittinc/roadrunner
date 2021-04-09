# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :set_repository, only: %i[show update]

  def index
    @repositories = Repository.all
  end

  def show; end

  def create
    @repository = Repository.new(repository_params)
    if @repository.save
      render 'repositories/show', formats: [:json]
    else
      render partial: 'repositories/error', formats: [:json]
    end
  end

  def update
    if @repository.update(repository_params)
      render 'repositories/show', formats: [:json]
    else
      render partial: 'repositories/error', formats: [:json]
    end
  end

  private

  def set_repository
    @repository = Repository.find(params[:id])
  end

  def repository_params
    params.require(:repository).permit(
      :project_id,
      :deploy_type,
      :supports_deploy,
      :name,
      :jira_project,
      :alias,
      :owner,
      slack_repository_info_attributes: %i[deploy_channel dev_channel dev_group feed_channel]
    )
  end
end

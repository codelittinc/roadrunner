# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :set_repository, only: %i[show update destroy]

  def index
    @repositories = Repository.all
  end

  def show; end

  def create
    @repository = CreateRepositoryService.new(repository_params).create

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

  def destroy
    @repository.destroy
    head :ok
  end

  private

  def set_repository
    @repository = Repository.find(params[:id])
  end

  def repository_params
    params.require(:repository).permit(
      :name,
      :friendly_name,
      :project_id,
      :owner,
      :deploy_type,
      :supports_deploy,
      :jira_project,
      :source_control_type,
      slack_repository_info_attributes: %i[deploy_channel dev_channel dev_group feed_channel]
    )
  end
end

# frozen_string_literal: true

class RepositoriesController < ApplicationController
  def index
    repositories = Repository.all
    render json: repositories.to_json
  end

  def create
    repository = Repository.new(repository_params)
    if repository.save
      render json: repository.to_json
    else
      render json: { error: repository.errors }
    end
  end

  def update
    repository = Repository.find(params[:id])
    if repository.update(repository_params)
      render json: repository.to_json
    else
      render json: { error: repository.errors }
    end
  end

  private

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

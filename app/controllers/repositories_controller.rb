# frozen_string_literal: true

class RepositoriesController < ApplicationController
  def create
    repository = Repository.new(repository_params)
    if repository.save
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

# frozen_string_literal: true

class RepositoriesController < ApplicationController
  def create
    repository = Repository.new(repository_params)
    if repository.save
      SlackRepositoryInfo.create(repository_id: repository.id)
      render json: repository.to_json
    else
      render json: { error: repository.errors }
    end
  end

  private

  def repository_params
    params.require(:repository).permit(:project_id, :deploy_type, :supports_deploy, :name, :jira_project, :alias, :owner)
  end
end

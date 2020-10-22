# frozen_string_literal: true

class CreateRepositoryService
  def initialize(project, params)
    @params = params
    @project = project
  end

  def create
    repository = Repository.create!(
      project: @project,
      name: name,
      owner: owner,
      deploy_type: deploy_type,
      supports_deploy: supports_deploy,
      alias: repo_alias,
      jira_project: jira_project
    )
    github_repo = Clients::Github::Repository.new.get_repository(repository.full_name) if repository
    Clients::Github::Hook.new.create(repository.full_name) if github_repo
  end

  private

  def name
    @params[:name]
  end

  def owner
    @params[:owner] || 'codelittinc'
  end

  def deploy_type
    @params[:deploy_type]
  end

  def supports_deploy
    @params[:supports_deploy]
  end

  def repo_alias
    @params[:alias]
  end

  def jira_project
    @params[:jira_project]
  end
end

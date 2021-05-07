# frozen_string_literal: true

class CreateRepositoryService
  def initialize(params)
    @params = params
  end

  def create
    repository = Repository.create(
      name: name,
      friendly_name: friendly_name,
      project_id: project_id,
      owner: owner,
      deploy_type: deploy_type,
      supports_deploy: supports_deploy,
      jira_project: jira_project,
      source_control_type: source_control_type
    )

    if repository && slack_repository_info_attributes
      SlackRepositoryInfo.create(
        repository: repository,
        deploy_channel: slack_repository_info_attributes['deploy_channel'],
        dev_channel: slack_repository_info_attributes['dev_channel'],
        dev_group: slack_repository_info_attributes['dev_group'],
        feed_channel: slack_repository_info_attributes['feed_channel']
      )
    end

    github_repo = Clients::Github::Repository.new.get_repository(repository.full_name) if repository
    Clients::Github::Hook.new.create(repository.full_name) if github_repo

    repository
  end

  private

  def name
    @params[:name]
  end

  def friendly_name
    @params[:friendly_name]
  end

  def project_id
    @params[:project_id]
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

  def jira_project
    @params[:jira_project]
  end

  def slack_repository_info_attributes
    @params[:slack_repository_info_attributes]
  end

  def source_control_type
    @params[:source_control_type]
  end
end

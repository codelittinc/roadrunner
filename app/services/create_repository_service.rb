# frozen_string_literal: true

class CreateRepositoryService
  def initialize(params)
    @params = params
  end

  def create
    repository = Repository.create(
      name:,
      friendly_name:,
      project_id:,
      owner:,
      deploy_type:,
      supports_deploy:,
      jira_project:,
      source_control_type:
    )

    if repository && slack_repository_info_attributes
      SlackRepositoryInfo.create(
        repository:,
        deploy_channel: slack_repository_info_attributes['deploy_channel'],
        dev_channel: slack_repository_info_attributes['dev_channel'],
        dev_group: slack_repository_info_attributes['dev_group'],
        feed_channel: slack_repository_info_attributes['feed_channel']
      )
    end

    source_control_repo = Clients::SourceControlClient.new(repository).repository if repository
    Clients::SourceControlClient.new(repository).create_hook if source_control_repo

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
    @params[:slack_repository_info_attributes]&.to_h&.with_indifferent_access
  end

  def source_control_type
    @params[:source_control_type]
  end
end

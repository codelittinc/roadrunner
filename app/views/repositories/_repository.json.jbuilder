# frozen_string_literal: true

json.id repository.id
json.project Project.find(repository.project_id)
json.friendly_name repository.friendly_name
json.deploy_type repository.deploy_type
json.supports_deploy repository.supports_deploy
json.name repository.name
json.jira_project repository.jira_project
json.owner repository.owner

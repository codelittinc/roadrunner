# frozen_string_literal: true

json.extract! repository, :id, :created_at, :updated_at, :deploy_type, :supports_deploy, :name, :jira_project, :owner, :source_control_type, :active, :base_branch, :filter_pull_requests_by_base_branch, :slug

json.project repository.project
json.slack_repository_info do
  json.extract! repository.slack_repository_info, :id, :created_at, :updated_at, :repository_id, :dev_group, :deploy_channel, :dev_channel, :feed_channel
end

json.applications repository.applications do |application|
  json.extract! application, :id, :environment, :created_at, :updated_at, :repository_id
end

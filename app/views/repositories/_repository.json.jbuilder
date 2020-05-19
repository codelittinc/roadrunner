json.projectName repository.project.name
json.deployChannel repository.slack_repository_info.deploy_channel
json.devChannel repository.slack_repository_info.dev_channel
json.devGroup repository.slack_repository_info.dev_group
json.deployWithTag repository.deploy_with_tag?
json.supportsDeploy repository.supports_deploy?
json.servers repository.servers.map(&:link)
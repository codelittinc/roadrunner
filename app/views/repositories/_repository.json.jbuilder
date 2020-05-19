json.name repository.name
json.devGroup repository.slack_repository_info.dev_group
json.channel repository.slack_repository_info.dev_channel
json.deployChannel repository.slack_repository_info.deploy_channel if repository.slack_repository_info.deploy_channel
json.owner 'codelittinc'
json.supportsDeploy repository.supports_deploy?
json.deployWithTag repository.deploy_with_tag? if repository.deploy_type
json.servers repository.servers.map(&:alias).reject(&:nil?) if repository.servers.length > 0
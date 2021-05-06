# frozen_string_literal: true

json.id application.id
json.project_name application.repository.project.name
json.latest_release application.latest_release
# @TODO: move this logic to the application
json.environment application.environment
json.repository application.repository, partial: 'repositories/repository', as: :repository
json.server application.server, partial: 'servers/server', as: :server

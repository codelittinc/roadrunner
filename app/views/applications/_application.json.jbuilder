# frozen_string_literal: true

json.id application.id
json.project_name application.repository.project.name
json.external_identifier application.external_identifier
# @TODO: move this logic to the application
json.environment application.environment
json.repository application.repository, partial: 'repositories/repository', as: :repository
json.server application.server, partial: 'servers/server', as: :server

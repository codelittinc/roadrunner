# frozen_string_literal: true

json.id application.id
json.name application.repository.project.name
json.version application.version
json.external_identifier application.external_identifier
# @TODO: move this logic to the application
json.environment application.environment
json.server application.server, partial: 'servers/server', as: :server

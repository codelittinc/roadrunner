# frozen_string_literal: true

json.array! @server_incidents, partial: 'servers/incident', as: :incident

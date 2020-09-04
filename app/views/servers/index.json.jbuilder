# frozen_string_literal: true

json.array! @servers, partial: 'servers/show', as: :server

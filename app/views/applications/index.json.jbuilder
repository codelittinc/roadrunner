# frozen_string_literal: true

json.array! @applications, partial: 'applications/show', as: :applications

# frozen_string_literal: true

json.array! @pull_requests, partial: 'pull_requests/pull_request', as: :pull_request

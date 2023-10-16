# frozen_string_literal: true

# _pull_request.json.jbuilder

json.extract! pull_request, :id, :created_at, :merged_at, :state

json.project_id pull_request.repository.external_project_id

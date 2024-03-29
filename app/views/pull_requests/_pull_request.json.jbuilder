# frozen_string_literal: true

# _pull_request.json.jbuilder

json.extract! pull_request, :id, :created_at, :merged_at, :state, :title, :backstage_user_id, :repository_id

json.project_id pull_request.repository.external_project_id

json.reviews pull_request.pull_request_reviews do |review|
  json.extract! review, :username, :backstage_user_id
end

json.code_comments pull_request.code_comments.size

json.link pull_request.link

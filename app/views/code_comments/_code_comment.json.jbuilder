# frozen_string_literal: true

json.extract! code_comment, :comment, :author_id, :published_at
json.pull_request_owner code_comment.pull_request.backstage_user_id

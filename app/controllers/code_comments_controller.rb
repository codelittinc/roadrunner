# frozen_string_literal: true

class CodeCommentsController < ApplicationController
  def index
    start_date = params[:start_date]
    end_date = params[:end_date]
    project_id = params[:project_id]

    @code_comments = CodeComment.joins(pull_request: :repository)
                                .where(published_at: start_date..end_date)
                                .where(repositories: { external_project_id: project_id })
  end
end

# frozen_string_literal: true

class PullRequestsController < ApplicationController
  def index
    backstage_user_id = params[:backstage_user_id]
    start_date = params[:start_date]
    end_date = params[:end_date]
    state = params[:state]
    project_id = params[:project_id]

    @pull_requests = PullRequest.where(backstage_user_id:, created_at: start_date..end_date, state:)
    return unless project_id

    @pull_requests = @pull_requests.joins(:repository).where(repository: { external_project_id: project_id })
  end
end

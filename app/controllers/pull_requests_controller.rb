# frozen_string_literal: true

class PullRequestsController < ApplicationController
  def index
    start_date = params[:start_date]
    end_date = params[:end_date]
    state = params[:state]

    @pull_requests = PullRequest.where(created_at: start_date..end_date, state:)

    project_id = params[:project_id]
    return unless project_id

    @pull_requests = @pull_requests.joins(:repository).where(repository: { external_project_id: project_id })

    backstage_user_id = params[:backstage_user_id]
    return unless backstage_user_id

    @pull_requests = @pull_requests.where(backstage_user_id:)
  end
end

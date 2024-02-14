# frozen_string_literal: true

class PullRequestsController < ApplicationController
  before_action :set_pull_request, only: %i[show]

  def index
    @pull_requests = Rails.cache.fetch(pull_requests_cache_key, expires_in: 1.second) do
      start_date = params[:start_date]
      end_date = params[:end_date]
      state = params[:state]

      pull_requests = PullRequest.where(created_at: start_date..end_date).order(created_at: :desc)
      pull_requests = pull_requests.where(state:) if state

      project_id = params[:project_id]
      if project_id
        pull_requests = pull_requests.joins(:repository).where(repository: { external_project_id: project_id })
      end

      backstage_user_id = params[:user_id]
      pull_requests = pull_requests.where(backstage_user_id:) if backstage_user_id
      pull_requests
    end
  end

  def show; end

  private

  def set_pull_request
    @pull_request = PullRequest.find(params[:id])
  end

  def pull_requests_cache_key
    "asddaspull_requests_#{params[:project_id]}_#{params[:start_date]}_#{params[:end_date]}_#{params[:state]}_#{params[:user_id]}-2"
  end
end

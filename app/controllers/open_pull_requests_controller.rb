# frozen_string_literal: true

class OpenPullRequestsController < ApplicationController
  def index
    pull_requests = PullRequest.where(state: 'open')
    json = pull_requests.map do |pull_request|
      reviews = pull_request.pull_request_reviews.order(:updated_at)
      approved_by = reviews.where(state: 'approved').pluck(:username)
      reproved_by = reviews.where(state: 'changes_requested').pluck(:username)
      if reviews.any?
        changes_after_reviews = pull_request.pull_request_changes.where(created_at: reviews.last.updated_at..Time.zone.now).any?
      end

      {
        title: pull_request.title,
        link: pull_request.link,
        user: pull_request.user&.slack,
        state: pull_request.check_runs.last&.state,
        approved_by:,
        reproved_by:,
        changes_after_reviews:
      }
    end

    render json:
  end
end

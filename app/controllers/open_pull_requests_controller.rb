class OpenPullRequestsController < ApplicationController
  def index
    pull_requests = PullRequest.where(state: 'open')
    json = pull_requests.map do |pull_request|
      {
        title: pull_request.title,
        link: pull_request.github_link,
        user: pull_request.user&.slack
      }
    end

    render json: json
  end
end

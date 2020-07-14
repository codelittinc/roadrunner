class SlackController < ApplicationController
  def index
    pull_request = PullRequest.where(github_id: params[:github_id])
    @slack_message = SlackMessage.where(pull_request: pull_request).first

    render json: @slack_message
  end
end

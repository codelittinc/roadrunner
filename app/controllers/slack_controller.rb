class SlackController < ApplicationController
  def index
    repository = Repository.where(name: params[:repository_name]).first
    pull_request = PullRequest.where(github_id: params[:github_id], repository: repository).last
    @slack_message = SlackMessage.where(pull_request: pull_request).first

    render json: @slack_message
  end
end

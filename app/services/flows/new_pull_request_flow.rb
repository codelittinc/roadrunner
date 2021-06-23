# frozen_string_literal: true

module Flows
  class NewPullRequestFlow < BaseSourceControlFlow
    def execute
      user.save unless user.persisted?

      response = Clients::Slack::ChannelMessage.new(customer).send(new_pull_request_message, channel)
      slack_message = SlackMessage.new(ts: response['ts'], pull_request: current_pull_request)
      slack_message.save!

      Clients::Slack::Reactji.new(customer).send(reaction, channel, slack_message.ts) if branch

      current_pull_request&.update(ci_state: checkrun_state)
    end

    def can_execute?
      return if repository.nil?
      return unless pull_request.nil?
      return unless parser.new_pull_request_flow?

      !parser.draft && !PullRequest.deployment_branches?(parser.base, parser.head)
    end

    private

    def user
      @user ||= parser.user_by_source_control
    end

    def current_pull_request
      return @current_pull_request if @current_pull_request

      pr = PullRequest.new(
        head: parser.head,
        base: parser.base,
        title: parser.title,
        description: parser.description,
        repository: repository,
        user: user
      )

      pr.source = parser.build_source(pr)
      pr.save!

      @current_pull_request = pr
    end

    def new_pull_request_message
      Messages::PullRequestBuilder.new_pull_request_message(current_pull_request)
    end

    def branch
      return @branch if @branch

      @branch = Branch.where(name: current_pull_request.head, repository: repository).first_or_create
      @branch.update(pull_request: current_pull_request)
      @branch
    end

    def checkrun
      @checkrun ||= CheckRun.where(branch: branch).last
    end

    def checkrun_state
      @checkrun_state ||= checkrun&.state || 'pending'
    end

    def reaction
      reacts = { 'success' => 'white_check_mark',
                 'failure' => 'rotating_light',
                 'pending' => 'hourglass' }

      reacts[checkrun&.state] || 'hourglass'
    end
  end
end

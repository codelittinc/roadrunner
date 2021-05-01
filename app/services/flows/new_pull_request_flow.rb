# frozen_string_literal: true

module Flows
  class NewPullRequestFlow < BaseGithubFlow
    def execute
      user.save unless user.persisted?

      response = Clients::Slack::ChannelMessage.new.send(new_pull_request_message, channel)
      slack_message = SlackMessage.new(ts: response['ts'], pull_request: pull_request)
      slack_message.save!

      Clients::Slack::Reactji.new.send(reaction, channel, slack_message.ts) if branch

      pull_request&.update(ci_state: checkrun_state)
    end

    def can_execute?
      return if pull_request_exists?

      return unless parser.new_pull_request_flow?

      !parser.draft && !PullRequest.deployment_branches?(parser.base, parser.head)
    end

    private

    def user
      @user ||= parser.user_by_source_control
    end

    def pull_request
      return @pull_request if @pull_request

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

      @pull_request = pr
    end

    def new_pull_request_message
      Messages::PullRequestBuilder.new_pull_request_message(pull_request)
    end

    def branch
      return @branch if @branch

      @branch = Branch.where(name: pull_request.head, repository: repository).first_or_create
      @branch.update(pull_request: pull_request)
      @branch
    end

    def checkrun
      # @TODO: specify the pull request
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

# frozen_string_literal: true

module Flows
  class NewPullRequestFlow < BaseFlow
    def execute
      user.save unless user.persisted?
      repository.save unless repository.persisted?

      response = Clients::Slack::ChannelMessage.new.send(new_pull_request_message, channel)
      slack_message = SlackMessage.new(ts: response['ts'], pull_request: pull_request)
      slack_message.save!

      Clients::Slack::Reactji.new.send(reaction, channel, slack_message.ts) if branch

      pull_request&.update(ci_state: checkrun_state)
    end

    def can_execute?
      return if pull_request_exists?
      return unless action == 'opened' || action == 'ready_for_review'

      !parser.draft && !PullRequest.deployment_branches?(parser.base, parser.head)
    end

    private

    def action
      @params[:action]
    end

    def repository
      @repository ||= Repository.find_or_initialize_by(name: parser.repository_name)
    end

    def user
      @user ||= User.find_or_initialize_by(github: parser.username.downcase)
    end

    def pull_request_exists?
      PullRequest.find_by(repository: repository, github_id: parser.github_id)
    end

    def pull_request
      @pull_request ||= PullRequest.create(
        head: parser.head,
        base: parser.base,
        github_id: parser.github_id,
        title: parser.title,
        description: parser.description,
        owner: parser.owner,
        repository: repository,
        user: user
      )
    end

    def new_pull_request_message
      Messages::Builder.new_pull_request_message(pull_request)
    end

    def branch
      return @branch if @branch

      @branch = Branch.where(name: pull_request.head, repository: repository).first_or_create
      @branch.update(pull_request: pull_request)
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

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end
  end
end

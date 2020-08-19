module Flows
  class NewPullRequestFlow < BaseFlow
    def execute
      user.save unless user.persisted?
      repository.save unless repository.persisted?

      pull_request = PullRequest.new(
        head: parser.head,
        base: parser.base,
        github_id: parser.github_id,
        title: parser.title,
        description: parser.description,
        owner: parser.owner,
        repository: repository,
        user: user
      )

      pull_request.save!

      new_pull_request_message = Messages::Builder.new_pull_request_message(pull_request)
      channel = repository.slack_repository_info.dev_channel

      response = Clients::Slack::ChannelMessage.new.send(new_pull_request_message, channel)
      slack_message = SlackMessage.new(ts: response['ts'], pull_request: pull_request)
      slack_message.save!
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
  end
end

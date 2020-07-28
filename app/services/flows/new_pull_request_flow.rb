module Flows
  class NewPullRequestFlow < BaseFlow
    def execute
      user = User.find_or_initialize_by(github: pull_request_data[:username])
      repository = Repository.find_or_initialize_by(name: pull_request_data[:repository_name])

      user.save unless user.persisted?
      repository.save unless repository.persisted?

      pull_request = PullRequest.new(
        head: pull_request_data[:head],
        base: pull_request_data[:base],
        github_id: pull_request_data[:github_id],
        title: pull_request_data[:title],
        description: pull_request_data[:description],
        owner: pull_request_data[:owner],
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

    def flow?
      return unless action == 'opened' || action == 'ready_for_review'

      !pull_request_data[:draft] && !PullRequest.deployment_branches?(pull_request_data[:base], pull_request_data[:head])
    end

    private

    def pull_request_data
      @pull_request_data ||= Parsers::Github::NewPullRequestParser.new(@params).parse
    end

    def action
      @params[:action]
    end
  end
end

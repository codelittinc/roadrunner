module Flows
  class NewPullRequestFlow < BaseFlow
    def execute
      pull_request_data = Parsers::Github::NewPullRequestParser.new(@params).parse

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
        user: user,
      )

      pull_request.save!
    end

    def isFlow?
      return unless action == 'opened' || action == 'ready_for_review'

      pull_request_data = Parsers::Github::NewPullRequestParser.new(@params).parse
      return !pull_request_data[:draft] && !PullRequest.deployment_branches?(pull_request_data[:base], pull_request_data[:head])
    end

    private

    def action
      @params[:action]
    end
  end
end
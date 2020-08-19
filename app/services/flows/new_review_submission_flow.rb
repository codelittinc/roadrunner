module Flows
  class NewReviewSubmissionFlow < BaseFlow
    def execute
      if pull_request_review
        pull_request_review.update(state: parser.state)
      else
        PullRequestReview.create(pull_request: pull_request, username: parser.username, state: parser.state)
      end

      send_message
    end

    def can_execute?
      return false unless pull_request
      return false unless slack_message

      action == 'submitted'
    end

    private

    def pull_request_data
      return @pull_request_data if @pull_request_data

      @pull_request_data = Parsers::PullRequestParserGithub.new(@params)
      @pull_request_data.parse!
      @pull_request_data
    end

    def pull_request
      @pull_request ||= PullRequest.where(github_id: pull_request_data.github_id, repository: repository, head: pull_request_data.head).first
    end

    def pull_request_review
      @pull_request_review ||= PullRequestReview.find_by(pull_request: pull_request, username: parser.username)
    end

    def repository
      @repository ||= Repository.where(name: pull_request_data.repository_name).first
    end

    def action
      @action ||= @params[:action]
    end

    def slack_message
      @slack_message = pull_request.slack_message
    end

    def github_pull_request
      @github_pull_request ||= Clients::Github::PullRequest.new.get(repository.full_name, pull_request[:github_id])
    end

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end

    def send_message
      slack_ts = slack_message.ts
      if parser.state == PullRequestReview::REVIEW_STATE_CHANGES_REQUESTED
        message = Messages::Builder.notify_changes_request
        Clients::Slack::ChannelMessage.new.send(message, channel, slack_ts)
      elsif parser.message != ''
        message = Messages::Builder.notify_new_message
        Clients::Slack::ChannelMessage.new.send(message, channel, slack_ts)
      elsif !github_pull_request[:mergeable] && github_pull_request[:mergeable_state] == 'dirty'
        message = Messages::Builder.notify_pr_conflicts(pull_request)
        Clients::Slack::DirectMessage.new.send(message, pull_request.user.slack)
      end
    end
  end
end

# frozen_string_literal: true

class UpdatePullRequestsCommentsWorker
  include Sidekiq::Worker

  def perform(*_args)
    Tasks::UpdatePullRequestsCommentsTask.new.update!
  end
end

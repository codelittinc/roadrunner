# frozen_string_literal: true

class RemoveFlowsWorker
  include Sidekiq::Worker

  def perform(*_args)
    Rails.logger.info 'Removing flow requests older than 3 days ago...'

    FlowRequest.where('created_at < ? and error_message IS NULL', DateTime.now - 3.days).delete_all

    Rails.logger.info 'Flow requests removed successfully!'
  end
end

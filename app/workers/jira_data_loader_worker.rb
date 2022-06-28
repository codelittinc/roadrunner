# frozen_string_literal: true

class JiraDataLoaderWorker
  include Sidekiq::Worker

  def perform(*_args)
    Tasks::JiraSprintsUpdate.new.update!
  end
end

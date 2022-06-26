# frozen_string_literal: true

class AzureDataLoaderWorker
  include Sidekiq::Worker

  def perform(*_args)
    Tasks::AzureSprintsUpdate.new.update!
  end
end

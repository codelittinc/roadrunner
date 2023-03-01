# frozen_string_literal: true

class ContentNotionWorker
  include Sidekiq::Worker

  def perform(*_args)
    Rails.logger.info 'Updating notion content.'

    content = Clients::NotionApi::Client.new.content

    Rails.logger.debugger content

    ExternalResourceMetadata.new(key: 'notion-content', value: content).save!

    Rails.logger.info 'Notion content updated successfully!'
  end
end

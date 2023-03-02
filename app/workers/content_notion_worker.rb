# frozen_string_literal: true

class ContentNotionWorker
  include Sidekiq::Worker

  def perform(*_args)
    Rails.logger.info 'Saving notion content.'

    content = Clients::NotionApi::Client.new.content

    ExternalResourceMetadata.new(key: 'notion-content', value: content).save!

    Rails.logger.info 'Notion content saved successfully!'
  end
end

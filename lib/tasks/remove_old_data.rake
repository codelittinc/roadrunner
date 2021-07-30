# frozen_string_literal: true

namespace :cleanup do
  desc 'delete old data'
  task delete_old_data: :environment do
    Rails.logger.warn 'Starting to delete old data'
    FlowRequest.where(error_message: nil).destroy_all
  end
end

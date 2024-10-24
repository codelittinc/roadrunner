# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', nil),
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }

  config.on(:startup) do
    schedule_file = 'config/schedule.yml'

    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file)
  end

  config.error_handlers << proc do |ex, ctx_hash, _cfg|
    if Rails.env.production?
      job = ctx_hash[:job]['class']
      args = ctx_hash[:job]['args']

      message = "There was an error with the job: #{job} with arguments: #{args.join(',')}.\nThe error message is: #{ex}"
      RubyNotificationsClient::Channel.new.send(message, ENV.fetch('ERROR_NOTIFICATION_CHANNEL', nil))
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', nil),
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

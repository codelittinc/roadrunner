# frozen_string_literal: true

if defined?(Datadog)
  return unless Rails.env.production?

  Datadog.configure do |config|
    # Global settings
    config.runtime_metrics.enabled = true
    config.service = ENV.fetch('DATADOG_SITE_NAME', nil)

    # Tracing settings
    config.tracing.analytics.enabled = true
    config.tracing.partial_flush.enabled = true
    config.tracing.instrument :rails, service_name: ENV.fetch('DATADOG_SITE_NAME', nil)

    # CI settings
    config.ci.enabled = (ENV.fetch('DD_ENV', nil) == 'ci')
    config.ci.instrument :rspec

    # Keys
    config.api_key = ENV.fetch('DATADOG_API_KEY', nil)
  end
end

# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<SENSITIVE_DATA>') { ENV['GIT_AUTH_KEY'] }
end

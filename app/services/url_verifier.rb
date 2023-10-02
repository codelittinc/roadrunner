# frozen_string_literal: true

require 'net/http'
require 'uri'

class CustomResponse
  attr_reader :code, :body

  def initialize(code, body)
    @code = code
    @body = body
  end
end

class UrlVerifier
  MAX_RETRIES = 3
  RETRY_INTERVAL = 5 # seconds

  def self.call(url, interval = RETRY_INTERVAL)
    return CustomResponse.new('-', "Unable to reach #{url} after #{MAX_RETRIES} attempts") unless valid_url?(url)

    uri = URI(url)
    last_response = nil
    MAX_RETRIES.times do
      begin
        last_response = Net::HTTP.get_response(uri)
        break if last_response.is_a?(Net::HTTPSuccess)
      rescue StandardError => e
        last_response = CustomResponse.new('', e.message)
        Rails.logger.debug { "Attempt failed: #{e.message}" }
      end
      sleep interval
    end

    last_response
  end

  def self.valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end
end

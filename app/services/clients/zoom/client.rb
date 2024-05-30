# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'multipart_post'

module Clients
  module Zoom
    class Client
      def download_recording(download_url, download_token)
        uri = URI(download_url)
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{download_token}"

        follow_redirects(uri, request)
      end

      def send_to_zapier(file_content, file_name)
        uri = URI(ENV.fetch('UPLOAD_MEETINGS_URL', nil))
        request = Net::HTTP::Post.new(uri)

        form_data = [
          ['file', file_content, { filename: file_name, content_type: 'application/octet-stream' }],
          ['file_name', file_name]
        ]

        request.set_form form_data, 'multipart/form-data'

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        if response.code.to_i == 200
          Rails.logger.debug { "Successfully sent #{file_name} to Zapier" }
        else
          Rails.logger.debug { "Failed to send #{file_name} to Zapier: #{response.body}" }
        end
      end

      private

      def follow_redirects(uri, request, limit = 10)
        raise 'Too many HTTP redirects' if limit.zero?

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        case response
        when Net::HTTPRedirection
          location = response['location']
          Rails.logger.debug { "Redirected to #{location}" }
          new_uri = URI(location)
          new_request = Net::HTTP::Get.new(new_uri)
          new_request['Authorization'] = request['Authorization']
          follow_redirects(new_uri, new_request, limit - 1)
        else
          response
        end
      end
    end
  end
end

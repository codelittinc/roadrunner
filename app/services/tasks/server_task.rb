# frozen_string_literal: true

require 'net/http'

module Tasks
  class ServerTask
    VALID_STATUS_CODE = %w[401 200 302].freeze

    def self.check_up_servers!
      servers = Server.where(active: true)

      Rails.logger.warn 'Starting to review the servers!'
      servers.each do |server|
        link = server.link

        link = "#{server.link}/health" if server.supports_health_check
        response = result_request(link)

        next if VALID_STATUS_CODE.include?(response.code)

        status_check = ServerStatusCheck.create!(
          server: server,
          code: response.code
        )

        ApplicationIncidentService.new.register_incident!(
          server.application,
          "Roadrunner is trying to reach #{link}, and is receiving:\n\ncode: #{response.code}\nmessage: #{response.body}",
          status_check
        )
      end
      Rails.logger.warn 'Finished to review the servers!'
    end

    def self.result_request(link, retries = 0)
      response = Net::HTTP.get_response(URI(link))

      return response if VALID_STATUS_CODE.include?(response.code)

      if retries <= 3
        sleep(3)
        return result_request(link, retries + 1)
      end

      response
    end
  end
end

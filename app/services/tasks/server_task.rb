# frozen_string_literal: true

module Tasks
  class ServerTask
    VALID_STATUS_CODE = %w[401 200 302 307].freeze

    def self.check_up_servers!
      servers = Server.where(active: true)

      servers.each do |server|
        link = server.link

        Rails.logger.debug { "Checking: #{link}" }
        link = "#{server.link}/health" if server.supports_health_check
        response = UrlVerifier.call(link)

        next if response.nil? || VALID_STATUS_CODE.include?(response.code)

        status_check = ServerStatusCheck.create!(
          server:,
          code: response.code
        )

        ApplicationIncidentService.new.register_incident!(
          server.application,
          "Roadrunner is trying to reach #{link}, and is receiving:\n\ncode: #{response.code}\nmessage: #{response.body}",
          status_check
        )
      end
    end
  end
end

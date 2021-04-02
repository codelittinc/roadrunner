# frozen_string_literal: true

require 'net/http'

module Tasks
  class ServerTask
    def self.check_up_servers!
      servers = Server.where(active: true)

      servers.each do |server|
        link = server.link
        link = "#{server.link}/health" if server.supports_health_check

        response = Net::HTTP.get_response(URI(link))
        code = response.code

        valid_status_codes = %w[401 200]

        next if valid_status_codes.include?(code)

        status_check = ServerStatusCheck.create!(
          server: server,
          code: code
        )

        ApplicationIncidentService.new.register_incident!(
          server,
          "Roadrunner is trying to reach #{link}, and is receiving:\n\ncode: #{response.code}\nmessage: #{response.body}",
          status_check
        )
      end
    end
  end
end

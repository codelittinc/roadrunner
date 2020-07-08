require 'net/http'

class HealthCheckController < ApplicationController
  def index
    servers = Server.where(active: true)
    render json: { status: :ok }, status: :ok

    Thread.new do
      servers.each do |server|
        link = server.link
        link = "#{server.link}/health" if server.supports_health_check

        response = get(link)
        code = response.code

        valid_status_codes = %w[401 200]

        status_check = ServerStatusCheck.create!(
          server: server,
          code: code
        )

        next if valid_status_codes.include?(code)

        slack_channel = server.repository.slack_repository_info.deploy_channel

        ServerIncidentService.new.register_incident!(
          server,
          "Roadrunner is trying to reach #{link}, and is receiving:\n\ncode: #{response.code}\nmessage: #{response.body}",
          status_check
        )
      end

      Thread.exit
    end
  end

  private

  def get(url)
    uri = URI(url)
    Net::HTTP.get_response(uri)
  end
end

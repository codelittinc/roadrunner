require 'net/http'

class HealthCheckController < ApplicationController
  def index 
    servers = Server.where(active: true)
    puts "Health check starting!"
    render json: { status: :ok }, status: :ok

    Thread.new do
      servers.each do |server|
        link = server.link
        link = "#{server.link}/health" if server.supports_health_check

        response = get(link)

        valid_status_codes = ["401", "200"]

        puts "#{link} #{response.code}"
        if !valid_status_codes.include?(response.code)
          slack_channel = server.repository.slack_repository_info.deploy_channel
          
          ServerIncidentService.new.register_incident!(
            server,
             "Roadrunner is trying to reach #{link}, and is receiving:\n\ncode: #{response.code}\nmessage: #{response.body}")
        end
      end

      Thread.exit
    end

  end

  private

  def get url
    uri = URI(url)
    Net::HTTP.get_response(uri)
  end
end

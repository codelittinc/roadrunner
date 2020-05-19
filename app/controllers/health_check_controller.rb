require 'net/http'

class HealthCheckController < ApplicationController
  def index 
    servers = Server.all
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
          message = ":fire: the server #{server.link} is down."
          
          if server.supports_health_check
            message = "#{message} Error: \n #{response.body}"
          end

          send_slack_message(slack_channel, message)
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

  def send_slack_message(channel, message)
    hostname = ENV['HOSTNAME']

    slack_api_key=ENV['SLACK_API_KEY']
    slack_api_url="#{ENV['SLACK_API_URL']}/channel-messages"

    uri = URI(slack_api_url)
    params = {
      bot: 'roadrunner',
      channel: channel,
      message: message
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', "Authorization" => slack_api_key})
    request.body = params.to_json
    
    response = http.request(request)
  end
end

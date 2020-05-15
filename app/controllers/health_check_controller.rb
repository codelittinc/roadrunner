require 'net/http'

class HealthCheckController < ApplicationController
  def index 
    servers = Server.where(supports_health_check: true)
    servers.each do |server|
      status = get_status(server.link)

      slack_channel = server.repository.slack_repository_info.deploy_channel
      message = ":fire: the server #{server.link} is down"
      send_slack_message(slack_channel, message)
    end
  end

  private

  def get_status url
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    res.code
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

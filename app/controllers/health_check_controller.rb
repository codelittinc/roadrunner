require 'net/http'

class HealthCheckController < ApplicationController
  def index 
    servers = Server.where(supports_health_check: true)
    servers.each do |server|
      status = get_status(server.link)

      if status == '200'
        slack_channel = server.repository.slack_repository_info.deploy_channel
        message = ":fire: the server #{server.link} is down"
        send_slack_message(slack_channel, message)
      end
    end
  end

  private

  def get_status url
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    res.code
  end

  def send_slack_message(channel, message)
    slack_api_key='eyJhbGciOiJIUzI1NiJ9.cm9hZHJ1bm5lcg.2RCJIS5rW7oggjzgCvu1xGrx3e0hBE-3zSraiLUa1eY'
    slack_api_url='https://prod-slack-api.herokuapp.com/channel-messages'

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

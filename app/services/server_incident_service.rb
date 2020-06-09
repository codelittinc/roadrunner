class ServerIncidentService
  def register_incident!(server, message, server_status_check = nil)
    if server
      slack_channel = server.slack_repository_info.deploy_channel
      slack_group = server.slack_repository_info.dev_group

      slack_message = ":fire: #{slack_group} :fire: #{server.environment&.upcase} - *#{server.link}* message: \n\n```#{message}```"

      ServerIncident.create!(
        server: server,
        message: message,
        server_status_check: server_status_check
      )

      Clients::Slack::ChannelMessage.new.send(
        slack_message,
        slack_channel
      )
    end
  end
end
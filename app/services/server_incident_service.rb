class ServerIncidentService
  def register_incident!(server, message, server_status_check = nil)
    if server
      slack_channel = server.slack_repository_info.deploy_channel
      slack_group = server.slack_repository_info.dev_group

      recurrent = ServerIncident.where(
        server: server,
        created_at: (Time.now - 10.minutes)..Time.now,
        message: message
      ).any?

      ServerIncident.create!(
        server: server,
        message: message,
        server_status_check: server_status_check
      )

      message_max_size = 150

      short_message = message[0..message_max_size]
      repository = server.repository
      slack_message = ":fire: <#{repository.github_link}|#{repository.name}> environment :fire:<#{server.link}|#{server.environment&.upcase}>:fire: \n ``` #{short_message}```"

      unless recurrent
        response = Clients::Slack::ChannelMessage.new.send(slack_message, slack_channel)

        if message.size > message_max_size
          final_message = "```#{message}````"
          Clients::Slack::ChannelMessage.new.send(
            final_message,
            slack_channel,
            response['ts']
          )
        end
      end
    end
  end
end

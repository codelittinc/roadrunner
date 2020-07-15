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
      icons = {
        qa: ':droplet:',
        prod: ':fire:'
      }

      icon = server.environment ? icons[server.environment.to_sym] : icons[:prod]
      main_message = "#{icon} <#{repository.github_link}|#{repository.name}> environment #{icon}<#{server.link}|#{server.environment&.upcase}>#{icon} \n ``` #{short_message}```"

      unless recurrent
        response = Clients::Slack::ChannelMessage.new.send(main_message, slack_channel)
        timestamp = response['ts']
        slack_message = SlackMessage.new
        slack_message.ts = timestamp
        slack_message.text = main_message
        slack_message.save

        if message.size > message_max_size
          final_message = "```#{message}````"
          Clients::Slack::ChannelMessage.new.send(
            final_message,
            slack_channel,
            timestamp
          )
        end
      end
    end
  end
end

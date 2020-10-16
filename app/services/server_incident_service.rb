# frozen_string_literal: true

class ServerIncidentService
  attr_reader :recurrent_server_incident, :current_server_incident

  ICONS = {
    qa: ':droplet:',
    prod: ':fire:'
  }.freeze

  MESSAGE_MAX_SIZE = 150
  GRAYLOG_MESSAGE_TYPE = 'graylog'
  SENTRY_MESSAGE_TYPE = 'sentry'

  def register_incident!(server, error_message, server_status_check = nil, message_type = GRAYLOG_MESSAGE_TYPE)
    return unless server
    return if ignore_incident?(error_message)

    @recurrent_server_incident ||= ServerIncident.find_by(
      server: server,
      created_at: (Time.zone.now - 1.day)..Time.zone.now,
      message: error_message
    )

    slack_repository_info = server.slack_repository_info
    slack_channel = slack_repository_info.feed_channel || slack_repository_info.deploy_channel

    create_incident(server, error_message, server_status_check)

    repository = server.repository
    icon = server.environment ? ICONS[server.environment.to_sym] : ICONS[:prod]
    short_message = message_type == GRAYLOG_MESSAGE_TYPE ? "```#{error_message[0..MESSAGE_MAX_SIZE]}```" : error_message
    slack_message = "#{icon} <#{repository.github_link}|#{repository.name}> environment #{icon}<#{server.link}|#{server.environment&.upcase}>#{icon} \n #{short_message}"

    notify_team!(slack_message, error_message, slack_channel, message_type) if create_new_recurrent_incident?
  end

  private

  def notify_team!(slack_message, error_message, slack_channel, message_type)
    response = Clients::Slack::ChannelMessage.new.send(slack_message, slack_channel)
    obj = SlackMessage.new
    obj.ts = response['ts']
    obj.text = slack_message
    obj.save
    current_server_incident.update(slack_message_id: obj.id)

    if error_message.size > MESSAGE_MAX_SIZE && message_type == GRAYLOG_MESSAGE_TYPE
      final_message = "```#{error_message}```"
      Clients::Slack::ChannelMessage.new.send(
        final_message,
        slack_channel,
        response['ts']
      )
    end
  end

  def create_new_recurrent_incident?
    recurrent_server_incident.nil? || recurrent_server_incident.state?(:completed)
  end

  def create_incident(server, error_message, server_status_check)
    if create_new_recurrent_incident?
      @current_server_incident = ServerIncident.create!(
        server: server,
        message: error_message,
        server_status_check: server_status_check
      )
    else
      ServerIncidentInstance.create!(server_incident: recurrent_server_incident)
    end
  end

  def ignore_incident?(error_message)
    ServerIncidentType.find { |type| error_message.match?(type.regex_identifier) }.present?
  end
end

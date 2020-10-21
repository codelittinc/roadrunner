# frozen_string_literal: true

class ServerIncidentService
  attr_reader :current_server_incident, :error_message, :message_type, :recurrent_server_incident, :server

  ICONS = {
    qa: ':droplet:',
    prod: ':fire:'
  }.freeze

  MESSAGE_MAX_SIZE = 150
  GRAYLOG_MESSAGE_TYPE = 'graylog'
  SENTRY_MESSAGE_TYPE = 'sentry'

  def register_incident!(server, error_message, server_status_check = nil, message_type = GRAYLOG_MESSAGE_TYPE)
    @server ||= server
    @error_message ||= error_message
    @message_type ||= message_type

    return unless server
    return if ignore_incident?

    @recurrent_server_incident ||= ServerIncident.find_by(
      server: server,
      created_at: (Time.zone.now - 1.day)..Time.zone.now,
      message: error_message
    )

    create_incident(server_status_check)

    notify_team! if create_new_recurrent_incident? && !dev_server?
  end

  private

  def notify_team!
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

  def create_incident(server_status_check)
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

  def ignore_incident?
    ServerIncidentType.find { |type| error_message.match?(type.regex_identifier) }.present?
  end

  def slack_repository_info
    server.slack_repository_info
  end

  def slack_channel
    slack_repository_info.feed_channel || slack_repository_info.deploy_channel
  end

  def repository
    server.repository
  end

  def short_message
    message_type == GRAYLOG_MESSAGE_TYPE ? "```#{error_message[0..MESSAGE_MAX_SIZE]}```" : error_message
  end

  def slack_message
    "#{icon} <#{repository.github_link}|#{repository.name}> environment #{icon}<#{server.link}|#{server.environment&.upcase}>#{icon} \n #{short_message}"
  end

  def icon
    server.environment ? ICONS[server.environment.to_sym] : ICONS[:prod]
  end

  def dev_server?
    server.environment&.include?(ServerIncident::DEVELOPMENT_ENVIRONMENT)
  end
end

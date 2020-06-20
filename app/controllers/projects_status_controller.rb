class ProjectsStatusController < ApplicationController
  def index
    servers = Server.all
    status = []

    days = (90.days.ago.to_date..Date.today).map { |date| date.strftime("%F") }

    incidents = servers.map do |server|
      {
        server: server,
        incidents_by_date: group_by_date(server.server_incidents),
        health_checks_by_date: group_by_date(server.server_status_checks)
      }
    end

    incidents_report = incidents.map do |incident|
      incidents_by_date = incident[:incidents_by_date]
      health_checks_by_date = incident[:health_checks_by_date]
      server = incident[:server]

      report = days.map do |day|
        {
          date: day,
          incidents: (incidents_by_date[day] || []).map do |incident| format_incident(incident) end + (health_checks_by_date[day] || []).map do |incident| format_health_check(incident) end,
        }
      end

      {
        alias: server.repository.alias,
        project_name: server.repository.project.name,
        repository: server.repository.name,
        environment: server.environment,
        server_link: server.link,
        server_id: server.id,
        report: report
      }
    end

    render json: incidents_report
  end

  def format_incident incident
    {
      id: incident.id,
      message: incident.message,
      server_id: incident.server.id,
      type: incident.incident_type,
      created_at: incident.created_at
    }
  end

  def format_health_check health_check
    {
      id: health_check.id,
      message: "Status #{health_check.code}",
      server_id: health_check.server.id,
      type: 'info',
      created_at: health_check.created_at
    }
  end

  def group_by_date(items)
    items.group_by do |incident|
      incident.created_at.strftime("%F")
    end
  end
end

class ProjectsStatusController < ApplicationController
  def index
    servers = Server.all
    status = []

    days = (3.month.ago.to_date..Date.today).map{ |date| date.strftime("%F") }

    incidents = servers.map do |server|
      {
        server: server,
        incidents_by_date: server.server_incidents.group_by do |incident|
          incident.created_at.strftime("%F")
        end
      }
    end

    incidents_report = incidents.map do |incident|
      incidents_by_date = incident[:incidents_by_date]
      server = incident[:server]

      report = days.map do |day|
        {
          date: day,
          incidents: incidents_by_date[day]
        }
      end

      {
        alias: server.repository.alias,
        repository: server.repository.name,
        environment: server.environment,
        server_link: server.link,
        report: report,
      }
    end

    render json: incidents_report
  end
end

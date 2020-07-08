class IncidentsController < ApplicationController
  def index
    date = Date.new(*params[:date].split('-').map(&:to_i)).all_day

    server = Server.find(params[:server_id])

    error_incidents = server.server_incidents.where(created_at: date)

    render json: error_incidents.map { |i| format_incident(i) }
  end

  def format_incident(incident)
    {
      id: incident.id,
      message: incident.message,
      server_id: incident.server.id,
      type: incident.incident_type,
      created_at: incident.created_at
    }
  end
end

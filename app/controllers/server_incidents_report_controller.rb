# frozen_string_literal: true

class ServerIncidentsReportController < ApplicationController
  before_action :set_server, only: %i[show]
  before_action :set_server_incidents, only: %i[show]
  before_action :set_status_checks, only: %i[show]

  def show
    events = [@server_incidents, @server_status_checks].flatten

    grouped_events_by_date = events.group_by do |event|
      event.created_at.strftime('%F')
    end

    json = grouped_events_by_date.map do |date, events_by_date|
      grouped_incidents_by_type = events_by_date.group_by(&:incident_type)
      {
        date: date,
        errors: grouped_incidents_by_type['error']&.size,
        warnings: grouped_incidents_by_type['warning']&.size,
        status_verifications: grouped_incidents_by_type['status_verification']&.size
      }
    end

    render json: json
  end

  private

  def set_server
    @server = Server.find(params[:id])
  end

  def events_date_range
    start_date = 90.days.ago
    end_date = Date.tomorrow

    start_date..end_date
  end

  def set_server_incidents
    @server_incidents = ServerIncident.where(created_at: events_date_range, server: @server)
  end

  def set_status_checks
    @server_status_checks = ServerStatusCheck.where(created_at: events_date_range, server: @server)
  end
end

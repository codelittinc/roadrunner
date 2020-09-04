# frozen_string_literal: true

class ServersController < ApplicationController
  before_action :set_server, only: %i[show]
  before_action :set_date, only: %i[show]
  before_action :set_server_incidents, only: %i[show]

  def index
    @servers = Server.where(active: true)
  end

  def show; end

  private

  def set_server
    @server = Server.find(params[:id])
  end

  def set_server_incidents
    @server_incidents = @server.server_incidents

    @server_incidents = @server_incidents.where(created_at: @date) if @date
  end

  def set_date
    return unless params[:date]

    @date = Date.new(*params[:date].split('-').map(&:to_i)).all_day
  end
end

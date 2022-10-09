# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show]

  def show; end

  def create
    @organization = Organization.find_or_initialize_by(notifications_id:)
    @organization.name = name
    @organization.notifications_key = notifications_key

    if @organization.save
      render json: @organization, status: :created
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:notifications_id, :name, :notifications_key)
  end

  def notifications_id
    @notifications_id ||= organization_params[:notifications_id]
  end

  def name
    @name ||= organization_params[:name]
  end

  def notifications_key
    @notifications_key ||= organization_params[:notifications_key]
  end
end

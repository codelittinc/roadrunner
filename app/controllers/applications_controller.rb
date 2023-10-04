# frozen_string_literal: true

class ApplicationsController < ApplicationController
  before_action :set_repository
  before_action :set_application, only: %i[show update destroy]

  def index
    @applications = @repository.applications.includes(:server, :external_identifiers)
    render json: @applications.as_json(include: %i[server external_identifiers])
  end

  def show
    render json: @application.as_json(include: %i[server external_identifiers])
  end

  def create
    @application = @repository.applications.build(application_params)

    if @application.save
      render json: @application.as_json(include: :server), status: :created, location: repository_application_url(@repository, @application)
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  def update
    ApplicationRecord.transaction do
      @application.external_identifiers.destroy_all
      @application.server.destroy if @application.server && !application_params[:server_attributes]

      raise ActiveRecord::Rollback unless @application.update(application_params)
    end

    if @application.errors.any?
      render json: @application.errors, status: :unprocessable_entity
    else
      render json: @application.as_json(include: :server)
    end
  end

  def destroy
    @application.destroy
    head :no_content
  end

  private

  def set_repository
    @repository = Repository.find(params[:repository_id])
  end

  def set_application
    @application = @repository.applications.includes(:server, :external_identifiers).find(params[:id])
  end

  def application_params
    params.require(:application).permit(:environment, :repository_id, server_attributes: %i[id link supports_health_check active environment], external_identifiers_attributes: %i[id text])
  end
end

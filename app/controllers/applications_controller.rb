# frozen_string_literal: true

class ApplicationsController < ApplicationController
  before_action :set_repository
  before_action :set_application, only: %i[show update destroy]

  # GET /repositories/:repository_id/applications
  def index
    @applications = @repository.applications.includes(:server, :external_identifiers)
    render json: @applications.as_json(include: %i[server external_identifiers])
  end

  # GET /repositories/:repository_id/applications/:id
  def show
    render json: @application.as_json(include: %i[server external_identifiers])
  end

  # POST /repositories/:repository_id/applications
  def create
    @application = @repository.applications.build(application_params)

    if @application.save
      render json: @application.as_json(include: :server), status: :created, location: repository_application_url(@repository, @application)
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /repositories/:repository_id/applications/:id
  def update
    if @application.update(application_params)
      render json: @application.as_json(include: :server)
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # DELETE /repositories/:repository_id/applications/:id
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

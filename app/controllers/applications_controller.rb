# frozen_string_literal: true

class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[show update edit destroy]
  before_action :set_repository, only: %i[update edit destroy new create]

  def index
    @applications = Application.all
  end

  def show; end

  # GET /repositories/new
  def new
    @application = Application.new
  end

  def edit; end

  def create
    @application = Application.new(environment: params[:environment], repository: @repository)
    @server = Server.new(environment: params[:environment], supports_health_check: params[:supports_health_check],
                         link: params[:link], active: params[:active], application: @application)

    Application.transaction do
      @application.save!
      @server.save!
    end

    redirect_to edit_repository_url(@repository.id)
  end

  def update
    Application.transaction do
      @application.update(environment: params[:environment])
      @application.server.update(environment: params[:environment], supports_health_check: params[:supports_health_check],
                                 link: params[:link], active: params[:active])
    end

    redirect_to edit_repository_url(@repository.id)
  end

  def destroy
    @application.server.destroy!
    redirect_to edit_repository_url(@repository.id)
  end

  private

  def application_params
    params.permit(:environment, :link, :supports_health_check, :active)
  end

  def set_application
    @application = Application.find(params[:id])
  end

  def set_repository
    @repository = Repository.find(params[:repository_id])
  end
end

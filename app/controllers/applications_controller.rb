# frozen_string_literal: true

class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[show update]

  def index
    applications = Application.all
    render json: applications.to_json
  end

  def show
    render json: @application
  end

  def create
    application = Application.new(application_params)
    if application.save
      render json: application.to_json
    else
      render json: { error: application.errors }
    end
  end

  def update
    if @application.update(application_params)
      render json: @application.to_json
    else
      render json: { error: @application.errors }
    end
  end

  private

  def application_params
    params.require(:application).permit(:repository_id, :environment, :version, :external_identifier)
  end

  def set_application
    @application = Application.find(params[:id])
  end
end

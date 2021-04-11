# frozen_string_literal: true

class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[show update destroy]

  def index
    @applications = Application.all
  end

  def show; end

  def create
    @application = Application.new(application_params)
    if @application.save
      render 'applications/show', formats: [:json]
    else
      render partial: 'applications/error', formats: [:json]
    end
  end

  def update
    if @application.update(application_params)
      render 'applications/show', formats: [:json]
    else
      render partial: 'applications/error', formats: [:json]
    end
  end

  def destroy
    @application.destroy
    head :ok
  end

  private

  def application_params
    params.require(:application).permit(:repository_id, :environment, :version, :external_identifier)
  end

  def set_application
    @application = Application.find(params[:id])
  end
end

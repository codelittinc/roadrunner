# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[update destroy]
  ALLOWED_EXPANDS = %w[applications].freeze

  def index
    @projects = Project.all
  end

  def show
    q = Project
    @expand.each do |e|
      q = q.includes(e.to_sym)
    end
    @project = q.friendly.find(params[:id])
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      render 'projects/create', formats: [:json]
    else
      render partial: 'projects/error', formats: [:json]
    end
  end

  def update
    if @project.update(project_params)
      render 'projects/create', formats: [:json]
    else
      render partial: 'projects/error', formats: [:json]
    end
  end

  def destroy
    @project.destroy
    head :ok
  end

  private

  def project_params
    params.require(:project).permit(:name, :slug)
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def allowed_expands
    ALLOWED_EXPANDS
  end
end

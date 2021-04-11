# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: [:destroy]
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

  def destroy
    @project.destroy
    head :ok
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def allowed_expands
    ALLOWED_EXPANDS
  end
end

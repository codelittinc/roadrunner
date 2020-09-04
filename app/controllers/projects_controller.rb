# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show]

  def show; end

  private

  def set_project
    @project = Project.friendly.find(params[:id])
  end
end

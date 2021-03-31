# frozen_string_literal: true

class ProjectsController < ApplicationController
  ALLOWED_EXPANDS = %w[applications].freeze

  def show
    q = Project
    @expand.each do |e|
      q = q.includes(e.to_sym)
    end
    @project = q.friendly.find(params[:id])
  end

  private

  def allowed_expands
    ALLOWED_EXPANDS
  end
end

# frozen_string_literal: true

class ChangelogsController < ApplicationController
  def index
    application = Application.find(params[:application_id])
    changelog = ChangelogsService.new(application).changelog
    render json: changelog
  end
end

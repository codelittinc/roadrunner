# frozen_string_literal: true

class ChangelogsController < ApplicationController
  def index
    changelog = ChangelogsService.new(params[:application_id]).changelog
    render json: changelog
  end
end

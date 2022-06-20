# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def index
    render json: { status: 200 }
  end
end

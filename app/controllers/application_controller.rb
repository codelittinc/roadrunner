# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :set_expand, only: %i[show]

  def index
    render json: { status: 200 }
  end

  def show; end

  private

  def set_expand
    @expand = (params[:expand]&.split(',')&.filter { |e| allowed_expands.include?(e) }) || []
  end

  def allowed_expands
    []
  end
end

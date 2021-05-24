# frozen_string_literal: true

class FlowController < ApplicationController
  def create
    render json: { text: 'Roadrunner is processing your request.' }, status: :ok

    FlowExecutor.new((params[:flow] || params).merge(request.GET)).execute
  end
end

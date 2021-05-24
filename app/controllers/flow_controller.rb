# frozen_string_literal: true

class FlowController < ApplicationController
  def create
    Thread.new do
      Rails.application.executor.wrap do
        FlowExecutor.new((params[:flow] || params).merge(request.GET)).execute
      end
    end

    render json: { text: 'Roadrunner is processing your request.' }, status: :ok
  end
end

# frozen_string_literal: true

class FlowController < ApplicationController
  def create
    json = (params[:flow] || params).merge(request.GET).to_json
    flow_request = FlowRequest.create!(json:)

    if Rails.env.production?
      HardWorker.perform_async(flow_request.id)
    else
      FlowExecutor.call(flow_request)
    end

    render json: { text: 'Roadrunner is processing your request.' }, status: :ok
  end
end

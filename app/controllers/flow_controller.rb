# frozen_string_literal: true

class FlowController < ApplicationController
  def create
    json = (params[:flow] || params).merge(request.GET).to_json
    flow_request = FlowRequest.create!(json: json)

    FlowExecutor.new(flow_request).execute! if flow_request

    render json: { text: 'Roadrunner is processing your request.' }, status: :ok
  end
end

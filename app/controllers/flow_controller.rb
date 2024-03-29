# frozen_string_literal: true

class FlowController < ApplicationController
  def create
    # When slack sends a "challenge" it expects a response with its
    # value to validate the ownership of the subscriber.
    # More info: https://api.slack.com/apis/connections/events-api#handshake
    return render json: { challenge: params['challenge'] }, status: :ok if params['challenge']

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

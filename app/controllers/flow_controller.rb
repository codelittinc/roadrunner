# frozen_string_literal: true

class FlowController < ApplicationController
  def create
    # When slack sends a "challenge" it expects a response with its
    # value to validate the ownership of the subscriber.
    # More info: https://api.slack.com/apis/connections/events-api#handshake
    return render json: { challenge: params['challenge'] }, status: :ok if params['challenge']
    return zoom_challenge if params.dig('payload', 'plainToken')

    json = (params[:flow] || params).merge(request.GET).to_json
    flow_request = FlowRequest.create!(json:)

    if Rails.env.production?
      HardWorker.perform_async(flow_request.id)
    else
      FlowExecutor.call(flow_request)
    end

    render json: { text: 'Roadrunner is processing your request.' }, status: :ok
  end

  private

  def zoom_challenge
    plain_token = params.dig('payload', 'plainToken')
    secret = ENV.fetch('ZOOM_WEBHOOK_SECRET_TOKEN', nil)
    encrypted_token = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, plain_token)

    response_json = {
      plainToken: plain_token,
      encryptedToken: encrypted_token
    }

    render json: response_json, status: :ok
  end
end

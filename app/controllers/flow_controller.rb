class FlowController < ApplicationController
  def create
    Thread.new do
      sanitized_params = request.parameters.merge(JSON.parse(request.body.read).with_indifferent_access)
      FlowExecutor.new(sanitized_params).execute
    end

    render json: {
      status: 200
    }, status: :ok
  end
end

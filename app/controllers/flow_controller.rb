class FlowController < ApplicationController
  def create
    Thread.new do
      FlowExecutor.new(params).execute
    end

    render json: {
      status: 200
    }, status: :ok
  end
end

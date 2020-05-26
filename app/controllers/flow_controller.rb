class FlowController < ApplicationController
  def create
    FlowExecutor.new(params).execute

    render json: {
      status: 200
    }, status: :ok
  end
end

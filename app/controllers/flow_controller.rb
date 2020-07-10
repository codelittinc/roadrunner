class FlowController < ApplicationController
  def create
    Thread.new do
      FlowExecutor.new(params[:flow] || params).execute
    end

    render json: {
      status: 200
    }, status: :ok
  end
end

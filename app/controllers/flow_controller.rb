class FlowController < ApplicationController
  def create
    render json: {
      status: 200
    }, status: :ok

    FlowExecutor.new((params[:flow] || params).merge(request.GET)).execute
  end
end

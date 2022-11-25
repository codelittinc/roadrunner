# frozen_string_literal: true

class FlowExecutor
  def initialize(flow_request)
    @params = JSON.parse(flow_request.json).with_indifferent_access
    @flow_request = flow_request
  end

  def execute!
    flow = FlowBuilder.build(@flow_request)
    if flow
      @flow_request.update(flow_name: flow.class.name)
      flow.run
      @flow_request.update(executed: true)
    else
      send_no_result_message!
    end
  end

  private

  def send_no_result_message!
    message = Messages::GenericBuilder.notify_no_results_from_flow(@params[:text])
    username = @params[:user_name]
    Clients::Notifications::Direct.new.send(message, username) if username
  end
end

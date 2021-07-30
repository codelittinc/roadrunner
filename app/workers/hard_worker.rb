# frozen_string_literal: true

class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(flow_request_id)
    flow_request = FlowRequest.find_by(id: flow_request_id)
    begin
      FlowExecutor.new(flow_request).execute! if flow_request
    rescue StandardError => e
      message = [e.to_s, e.backtrace].flatten.join("\n")
      Rails.logger.error "ERROR: #{message}"
      flow_request.update(error_message: message)
    end
  end
end

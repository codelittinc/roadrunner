# frozen_string_literal: true

class FlowExecutor
  def initialize(params)
    @params = params
  end

  def execute
    executed = true
    flow_request = FlowRequest.create!(json: @params.to_json)

    classnames.each do |classname|
      classConst = Object.const_get("Flows::#{classname}")
      object = classConst.new(@params)
      executed = false
      next unless object.flow?

      executed = true
      flow_request.update(flow_name: object.class.name)

      begin
        object.run
        flow_request.update(executed: true)
      rescue Exception => e
        message = [e.to_s, e.backtrace].flatten.join("\n")
        flow_request.update(error_message: message)
        send_exception_message! if channel_name
        raise e
      end

      break
    end

    send_no_result_message! unless executed
  end

  private

  def files
    @files ||= Dir['./app/services/flows/*'].reject do |file|
      file.include?('base_flow')
    end
  end

  def classnames
    @classnames ||= files.map do |file|
      regex = %r{/([a-z_]+).rb}
      file.match(regex)[1].split('_').map(&:capitalize).join if file.match?(regex)
    end.compact
  end

  def send_channel_message_result(message, channel)
    Clients::Slack::ChannelMessage.new.send(message, channel)
  end

  def send_direct_message_result(message, username)
    Clients::Slack::DirectMessage.new.send(message, username)
  end

  def channel_name
    @channel_name ||= @params[:channel_name]
  end

  def user_name
    @user_name ||= @params[:user_name]
  end

  def send_no_result_message!
    message = Messages::Builder.notify_no_results_from_flow
    if channel_name
      send_channel_message_result(message, channel_name)
    elsif user_name
      send_direct_message_result(message, user_name)
    end
  end

  def send_exception_message!
    message = Messages::Builder.notify_exception_from_flow
    send_channel_message_result(message, channel_name)
  end
end

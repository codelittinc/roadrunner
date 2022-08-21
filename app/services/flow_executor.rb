# frozen_string_literal: true

class FlowExecutor
  def initialize(flow_request)
    @params = JSON.parse(flow_request.json).with_indifferent_access
    @flow_request = flow_request
  end

  def execute!
    executed = true

    classnames.each do |classname|
      classConst = Object.const_get("Flows::#{classname}")
      object = classConst.new(@params)
      executed = false
      next unless object.flow?

      executed = true
      @flow_request.update(flow_name: object.class.name)

      object.run
      @flow_request.update(executed: true)

      break
    end

    send_no_result_message! unless executed
  end

  private

  def files
    @files ||= Dir['./app/services/flows/*'].reject do |file|
      file.include?('base')
    end
  end

  def classnames
    @classnames ||= files.map do |file|
      regex = %r{/([a-z_]+).rb}
      file.match(regex)[1].split('_').map(&:capitalize).join if file.match?(regex)
    end.compact
  end

  def send_channel_message_result(message, channel)
    Clients::Notifications::Channel.new.send(message, channel)
  end

  def send_direct_message_result(message, username)
    Clients::Notifications::Direct.new.send(message, username)
  end

  def channel_name
    @channel_name ||= @params[:channel_name]
  end

  def user_name
    @user_name ||= @params[:user_name]
  end

  def send_no_result_message!
    message = Messages::GenericBuilder.notify_no_results_from_flow(@params[:text])
    send_direct_message_result(message, user_name) if user_name
  end
end

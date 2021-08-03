# frozen_string_literal: true

class FlowExecutor
  def initialize(flow_request)
    @params = JSON.parse(flow_request.json).with_indifferent_access
    @flow_request = flow_request
  end

  def execute!
    executed = true

    classnames.each do |classname|
      begin
        classConst = Object.const_get("Flows::#{classname}")
      rescue StandardError
        next
      end
      object = classConst.new(@params)
      executed = false
      is_flow = classConst.ancestors.include?(Flows::BaseFlow)
      next unless is_flow && object.flow?

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
    @files ||= Dir['./app/services/flows/**/*'].reject do |file|
      file.include?('base')
    end
  end

  def classnames
    @classnames ||= files.map do |file|
      regex = %r{flows/?(.+)?/([a-z_]+).rb}

      matches = file.match(regex)
      matches = matches.to_a.reject { |m| m.nil? || m&.include?('flows') }
      matches.map do |mat|
        mat.split('_').map(&:capitalize).join
      end.join('::')
    end.compact.reject(&:blank?)
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
    message = Messages::GenericBuilder.notify_no_results_from_flow
    send_direct_message_result(message, user_name) if user_name
  end
end

class FlowExecutor
  def initialize(params)
    @params = params
  end

  def execute
    files = Dir['./app/services/flows/**/*'].reject do |file|
        file.include?("base_flow")
    end

    classnames = files.map do |file|
      file.match(/\/([a-z_]+).rb/)[1].split('_').map(&:capitalize).join
    end

    flow_request = FlowRequest.create!(json: @params.to_json)

    classnames.each do |classname|
      classConst = Object.const_get("Flows::#{classname}")
      object = classConst.new(@params)

      if object.isFlow?
        flow_request.update(flow_name: object.class.name)

        begin
          object.run
          flow_request.update(executed: true)
        rescue Exception => ex
          flow_request.update(error_message: ex.to_s)
        end
      end
    end
  end
end
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

    classnames.each do |classname|
      classConst = Object.const_get("Flows::#{classname}")
      object = classConst.new(@params)
      puts "isFlow? #{object.isFlow}"
      object.run
    end
  end
end
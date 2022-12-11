# frozen_string_literal: true

class FlowBuilder
  def self.build(params)
    params_with_indifferent_access = JSON.parse(params.json).with_indifferent_access

    flows = classnames.map do |classname|
      ruby_class = Object.const_get("Flows::#{classname}")
      ruby_class.new(params_with_indifferent_access)
    end

    flows.find(&:flow?)
  end

  def self.classnames
    files.map do |file|
      regex = %r{/([a-z_]+).rb}
      file.match(regex)[1].split('_').map(&:capitalize).join if file.match?(regex)
    end.compact
  end

  def self.files
    Dir['./app/services/flows/*'].reject do |file|
      file.include?('base')
    end
  end
end
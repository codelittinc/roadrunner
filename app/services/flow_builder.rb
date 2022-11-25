# frozen_string_literal: true

class FlowBuilder
  def self.build(params)
    params_with_indifferent_access = JSON.parse(params.json).with_indifferent_access
    object = nil

    classnames.each do |classname|
      ruby_class = Object.const_get("Flows::#{classname}")
      instance = ruby_class.new(params_with_indifferent_access)

      if instance.flow?
        object = instance
        break
      end
    end
    object
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

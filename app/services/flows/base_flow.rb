module Flows
  class BaseFlow
    def initialize(params)
      @params = params
    end

    def pre_run
      puts "Starting #{self.class.name}"
    end

    def run
      pre_run
      execute
      pos_run
    end

    def pos_run
      puts "Finishing #{self.class.name}"
    end

    def execute
      throw Error.new("Implement this method!")
    end

    def isFlow
      throw Error.new("Implement this method!")
    end
  end
end
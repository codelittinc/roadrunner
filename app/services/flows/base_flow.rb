module Flows
  class BaseFlow
    def initialize(params)
      @params = params
    end

    def pre_run
      Rails.logger.warn "Starting #{self.class.name}"
    end

    def run
      pre_run
      parse_data!
      execute
      pos_run
    end

    def pos_run
      Rails.logger.warn "Finishing #{self.class.name}"
    end

    def execute
      throw Error.new('Implement this method!')
    end

    def flow?
      return unless can_parse?

      parse_data!
      can_execute?
    end

    def can_parse?
      parser&.can_parse?
    end

    def can_execute?
      raise 'override this method'
    end

    def parse_data!
      parser&.parse!
    end

    def parser
      @parser ||= ParserFinder.new(@params).find
    end
  end
end

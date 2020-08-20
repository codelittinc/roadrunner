module Parsers
  class BaseParser
    def initialize(json)
      @json = json
    end

    def can_parse?
      false
    end

    def parse!; end
  end
end

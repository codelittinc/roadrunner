# frozen_string_literal: true

module Parsers
  class BaseParser
    attr_reader :data

    def initialize(json)
      @json = json
    end

    def can_parse?
      false
    end

    def parse!; end

    def method_missing(m, *args, &); end
  end
end

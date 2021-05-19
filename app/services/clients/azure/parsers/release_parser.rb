# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class ReleaseParser
        attr_reader :tag_name, :created_by

        def initialize(json)
          @json = json.with_indifferent_access
          parse!
        end

        def parse!
          @tag_name = @json[:name]&.remove('refs/tags/')
          @created_by = @json.dig(:creator, :displayName) || @json.dig(:taggedBy, :name)
        end
      end
    end
  end
end

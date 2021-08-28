# frozen_string_literal: true

module Parsers
  class BaseAzureParser < BaseParser
    def real_branch_name(base_name)
      return unless base_name

      branch_name_regex = %r{refs/heads/(.*)}
      base_name.match?(branch_name_regex) ? base_name.match(branch_name_regex)[1] : nil
    end
  end
end

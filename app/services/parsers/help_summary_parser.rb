# frozen_string_literal: true

require 'ostruct'
module Parsers
  class HelpSummaryParser < BaseParser
    attr_reader :user_name, :channel_name, :text

    def can_parse?
      @json && @json[:text] == 'help'
    end

    def parse!
      @user_name = @json[:user_name]
      @text = @json[:text]
    end
  end
end

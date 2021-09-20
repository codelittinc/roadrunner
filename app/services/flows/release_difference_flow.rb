# frozen_string_literal: true

module Flows
  class ReleaseDifferenceFlow < BaseFlow
    def execute; end

    def can_execute?
      text.include?('release diff') && text.split.size == 4
    end

    private

    def text
      @text ||= @params[:text]
    end
  end
end

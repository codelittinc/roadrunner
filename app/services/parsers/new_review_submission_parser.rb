module Parsers
  class NewReviewSubmissionParser
    attr_reader :message, :state, :username

    def initialize(json)
      @json = json
    end

    def can_parse?
      @json && !!review
    end

    def parse!
      @message = review[:body]
      @state = review[:state]
      @username = review.dig(:user, :login)
    end

    private

    def review
      @json[:review]
    end
  end
end

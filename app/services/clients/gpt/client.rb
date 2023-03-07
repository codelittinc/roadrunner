# frozen_string_literal: true

module Clients
  module Gpt
    class Client

      def initialize
        @client = OpenAI::Client.new(access_token: ENV.fetch('GPT_KEY', nil))
      end

      def generate(prompt, max_tokens = 1000)
        response = @client.completions(
          parameters: {
            model: 'text-davinci-003',
            prompt:,
            max_tokens:
          }
        )

        choices = response['choices']
        response = choices.pluck('text').join
        response.strip.gsub(/^"/, '').gsub(/"$/, '').gsub(/^'/, '').gsub(/'$/, '')
      end

      def process_question(question)
        Clients::Gpt::NlpProcessor.new.process_question(question)
      end
    end
  end
end

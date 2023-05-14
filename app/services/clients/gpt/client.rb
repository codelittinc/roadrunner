# frozen_string_literal: true

module Clients
  module Gpt
    class Client
      def initialize
        @client = OpenAI::Client.new(access_token: ENV.fetch('GPT_KEY', nil))
      end

      def generate(prompt, max_tokens = 1000)
        response = @client.chat(
          parameters: {
            model: 'gpt-4',
            messages: [
              { role: 'system', content: 'You are a helpful and creative assistant.' },
              { role: 'user', content: prompt }
            ],
            max_tokens:
          }
        )

        choices = response['choices'].first
        message = choices['message']['content']
        message.strip.gsub(/^"/, '').gsub(/"$/, '').gsub(/^'/, '').gsub(/'$/, '')
      end
    end
  end
end

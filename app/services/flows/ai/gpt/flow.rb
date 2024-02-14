# frozen_string_literal: true

module Flows
  module Ai
    module Gpt
      class Flow < BaseFlow
        delegate :user_name, :prompt, :text, to: :parser

        def execute
          response = Clients::Gpt::Client.new.generate(prompt)

          message = "Prompt: \n\n *#{prompt}* \n \n Response: \n\n #{response}"

          Clients::Notifications::Direct.new.send(message, user_name)
        end

        def can_execute?
          text&.split&.first == 'ask'
        end
      end
    end
  end
end

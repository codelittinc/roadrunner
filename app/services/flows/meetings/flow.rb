# frozen_string_literal: true

module Flows
  module Meetings
    class Flow < BaseFlow
      delegate :name, to: :parser

      def execute
        client = Clients::Zoom::Client.new
        response = client.download_recording(parser.download_url, parser.download_token)

        return unless response.code.to_i == 200

        file_content = response.body
        formatted_name = "#{Time.zone.now.strftime('%m/%d/%Y')} - #{parser.name}.mp4"
        client.send_to_zapier(file_content, formatted_name)
      end

      def can_execute?
        parser.meeting_id.present?
      end
    end
  end
end

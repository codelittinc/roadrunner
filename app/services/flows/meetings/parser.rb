# frozen_string_literal: true

module Flows
  module Meetings
    class Parser < Parsers::BaseParser
      attr_reader :meeting_id, :name, :download_url, :download_token

      def can_parse?
        @json.dig('payload', 'object', 'topic').present?
      end

      def parse!
        object = @json.dig('payload', 'object')

        recording_file = object['recording_files'].find do |file|
          file['file_extension'] == 'MP4'
        end

        @name = object['topic']
        @meeting_id = recording_file['meeting_id']
        @download_url = recording_file['download_url']
        @download_token = @json['download_token']
      end
    end
  end
end

# frozen_string_literal: true

module Clients
  module NotionApi
    class Client
      def initialize
        @client = Notion::Client.new(token: ENV.fetch('NOTION_KEY', nil))
      end

      def content
        text_content = ''
        all_pages.each do |page|
          blocks_children(page.id).each do |block|
            text_content += block_content(block)
          end
        end
        text_content
      end

      private

      def all_pages
        filter = { 'filter' => { 'value' => 'page', 'property' => 'object' } }
        @client.search(filter).results
      end

      def blocks_children(page_id)
        @client.block_children(block_id: page_id).results
      end

      def block_content(block)
        text = ''
        block.paragraph&.rich_text&.each do |rich_text|
          text += rich_text.text.content unless rich_text&.text&.content.nil?
        end
        text
      end
    end
  end
end

# frozen_string_literal: true

require 'json'
require 'net/http'
require 'rss'
require 'date'

module Flows
  module Notifications
    module IosReleases
      class Flow < BaseFlow
        delegate :name, :use_mock, :slack_channel, to: :parser

        FEED_URL = 'https://developer.apple.com/news/releases/rss/releases.rss'

        ReleaseItem = Struct.new(:title, :pubDate, :description, keyword_init: true)

        def execute
          latest_item = use_mock ? mock_ipad_release : fetch_latest_ipad_release

          return unless latest_item

          version = latest_item.title
          notify_new_release(version, latest_item.description)
        end

        def can_execute?
          @params[:name] == 'check-ios-releases'
        end

        private

        def mock_ipad_release
          ReleaseItem.new(
            title: 'iPadOS 17.4.1',
            pubDate: Time.zone.now,
            description: 'This release includes important bug fixes and security updates for your iPad.'
          )
        end

        def fetch_latest_ipad_release
          uri = URI(FEED_URL)
          response = Net::HTTP.get_response(uri)

          return nil unless response.is_a?(Net::HTTPSuccess)

          feed = RSS::Parser.parse(response.body, false)

          feed.items.find do |item|
            item.title.include?('iPadOS') && item.pubDate.to_date == Time.zone.today
          end
        rescue StandardError => e
          Rails.logger.error("Error fetching iPad releases: #{e.message}")
          nil
        end

        def notify_new_release(version, description)
          customer = Repository.default_project.customer

          message = [
            ':apple: *New iPad Release Detected* :apple:',
            '',
            "*Version:* #{version}",
            "*Release Date:* #{Time.zone.now.strftime('%B %d, %Y')}",
            '',
            '*Description:*',
            ">#{description}",
            '',
            'For more details, visit: <https://developer.apple.com/news/releases/|Apple Developer News>'
          ].join("\n")

          Clients::Notifications::Channel.new(customer).send(message, slack_channel)
        end
      end
    end
  end
end

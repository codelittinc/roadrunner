# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messages::ReleaseBuilder, type: :service do
  describe '.branch_compare_message' do
    describe 'with the Notifications format' do
      it 'returns a formatted message' do
        pr1 = FactoryBot.create(:pull_request, {
                                  title: 'Add leaseExpirationSized rest of expirations value',
                                  description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274'
                                })

        c1 = FactoryBot.create(:commit, {
                                 sha: '123456',
                                 message: 'Fix this thing\n
              this is my description
            ',
                                 pull_request: pr1
                               })

        c2 = FactoryBot.create(:commit, {
                                 sha: '13529',
                                 message: 'Update that feature\n
              this is my second description
            ',
                                 pull_request: pr1
                               })

        pr2 = FactoryBot.create(:pull_request, {
                                  title: 'Filter activity feed based on user preferences',
                                  description: %{
              If applied, this pull request will make the activity feed filter items based on the user's preferences (market and property type).

              ### Other minor changes:
              - Fixed unescaped character in a regex constant
              - Add an "empty state" component to show when no activities are available
              - Removed components and functions to handle the recent searches, as they will be replaced in the next PR with the homepage activity feed

              ### Card Link:
              https://codelitt.atlassian.net/browse/HUB-56
              https://codelitt.atlassian.net/browse/HUB-469
            }
                                })

        c3 = FactoryBot.create(:commit, {
                                 sha: '123456',
                                 message: 'Filter activity feed based on user preferences',
                                 pull_request: pr2
                               })

        message = %(Available in the release of *cool-repository*:
 - Fix this thing <https://codelitt.atlassian.net/browse/AYAPI-274|AYAPI-274>
 - Update that feature <https://codelitt.atlassian.net/browse/AYAPI-274|AYAPI-274>
 - Filter activity feed based on user preferences <https://codelitt.atlassian.net/browse/HUB-56|HUB-56> <https://codelitt.atlassian.net/browse/HUB-469|HUB-469>)

        expect(described_class.branch_compare_message([c1, c2, c3], 'slack', 'cool-repository')).to eq(message)
      end
    end
    describe 'with the Github format' do
      it 'returns a formatted message' do
        pr1 = FactoryBot.create(:pull_request, {
                                  title: 'Add leaseExpirationSized rest of expirations value',
                                  description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274'
                                })

        c1 = FactoryBot.create(:commit, {
                                 sha: '123456',
                                 message: 'Fix this thing\n
              this is my description
            ',
                                 pull_request: pr1
                               })

        c2 = FactoryBot.create(:commit, {
                                 sha: '13529',
                                 message: 'Update that feature\n
              this is my second description
            ',
                                 pull_request: pr1
                               })

        pr2 = FactoryBot.create(:pull_request, {
                                  title: 'Filter activity feed based on user preferences',
                                  description: %{
              If applied, this pull request will make the activity feed filter items based on the user's preferences (market and property type).

              ### Other minor changes:
              - Fixed unescaped character in a regex constant
              - Add an "empty state" component to show when no activities are available
              - Removed components and functions to handle the recent searches, as they will be replaced in the next PR with the homepage activity feed

              ### Card Link:
              https://codelitt.atlassian.net/browse/HUB-56
              https://codelitt.atlassian.net/browse/HUB-469
            }
                                })

        c3 = FactoryBot.create(:commit, {
                                 sha: '123456',
                                 message: 'Filter activity feed based on user preferences',
                                 pull_request: pr2
                               })

        message = %(Available in the release of *cool-repository*:
 - Fix this thing [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)
 - Update that feature [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)
 - Filter activity feed based on user preferences [HUB-56](https://codelitt.atlassian.net/browse/HUB-56) [HUB-469](https://codelitt.atlassian.net/browse/HUB-469))

        expect(described_class.branch_compare_message([c1, c2, c3], 'github', 'cool-repository')).to eq(message)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'UserSearches', type: :request do
  describe 'GET /index' do
    context 'with a slack name' do
      it 'returns an user' do
        term = 'batman'
        user = User.create({
                             slack: term
                           })

        get "/user_search/?term=#{term}"

        expect(response_body[:id]).to eq(user.id)
      end
    end

    context 'with a jira name' do
      it 'returns an user' do
        term = 'robin'
        user = User.create({
                             slack: 'batman',
                             jira: term
                           })

        get "/user_search/?term=#{term}"

        expect(response_body[:id]).to eq(user.id)
      end
    end

    context 'with a github name' do
      it 'returns an user' do
        term = 'Mr. Freeze'
        user = User.create({
                             slack: 'batman',
                             github: term
                           })

        get "/user_search/?term=#{term}"

        expect(response_body[:id]).to eq(user.id)
      end
    end
  end

  def response_body
    json = JSON.parse(response.body)
    (json || {}).with_indifferent_access
  end
end

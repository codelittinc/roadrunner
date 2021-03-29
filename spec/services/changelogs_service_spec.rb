# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangelogsService, type: :service do
  it 'returns the changelog' do
    application = FactoryBot.create(:application)
    changelog = ChangelogsService.new(application.id).changelog
    expect(changelog).to eq(
      [
        {
          version: '1.0.0',
          changes: [
            {
              message: 'Create form component',
              references: [
                'https://codelitt.atlassian.net/secure/RapidBoard.jspa?rapidView=35&projectKey=ADS&modal=detail&selectedIssue=ADS-68',
                'https://codelitt.atlassian.net/secure/RapidBoard.jspa?rapidView=35&projectKey=ADS&modal=detail&selectedIssue=ADS-69'
              ]
            },
            {
              message: 'Create input component',
              references: [
                'https://codelitt.atlassian.net/secure/RapidBoard.jspa?rapidView=35&projectKey=ADS&modal=detail&selectedIssue=ADS-66',
                'https://codelitt.atlassian.net/secure/RapidBoard.jspa?rapidView=35&projectKey=ADS&modal=detail&selectedIssue=ADS-69'
              ]
            }
          ]
        }
      ]
    )
  end
end

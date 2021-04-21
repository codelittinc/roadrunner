# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangelogsService, type: :service do
  it 'returns the changelog' do
    repository = FactoryBot.create(:repository)
    application = FactoryBot.create(:application, repository: repository)
    release = FactoryBot.create(:release, application: application, version: '1.0.0')
    pull_request = FactoryBot.create(
      :pull_request,
      repository: repository,
      description: '### Other minor changes:
      - Move files out to a utils file in UploadSection to shorten the file size and improve readability.
     ### Card Link:
     https://codelitt.atlassian.net/browse/HUB-2519
     ### Design Expected Screenshot
     ![image](https://user-images.githubusercontent.com/68696952/115034665.png)
     ### Implementation Screenshot or GIF
     ![Property Intelligence](https://user-images.githubusercontent.com/68696952.gif)
     ### Notes:
     Still WIP'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request: pull_request,
      message: 'Create form component'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request: pull_request,
      message: 'Create input component'
    )

    commits = release.commits
    version = release.version
    changelog = ChangelogsService.new(commits, version).changelog
    expect(changelog).to eq(
      {
        version: '1.0.0',
        changes: [
          {
            message: 'Create form component',
            references: [
              'https://codelitt.atlassian.net/browse/HUB-2519',
              'https://user-images.githubusercontent.com/68696952/115034665.png',
              'https://user-images.githubusercontent.com/68696952.gif'
            ]
          },
          {
            message: 'Create input component',
            references: [
              'https://codelitt.atlassian.net/browse/HUB-2519',
              'https://user-images.githubusercontent.com/68696952/115034665.png',
              'https://user-images.githubusercontent.com/68696952.gif'
            ]
          }
        ]
      }
    )
  end
end

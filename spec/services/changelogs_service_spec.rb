# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangelogsService, type: :service do
  let(:repository) { FactoryBot.create(:repository) }
  let(:release) do
    application = FactoryBot.create(:application, repository: repository)
    FactoryBot.create(:release, application: application, version: '1.0.0')
  end

  it 'returns the jira type changelogs' do
    pull_request = FactoryBot.create(
      :pull_request,
      title: 'This is a cool PR',
      repository: repository,
      description: '### Other minor changes:
        - Move files out to a utils file in UploadSection to shorten the file size and improve readability.
      ### Card Link:
      https://codelitt.atlassian.net/browse/HUB-2519
      ### Design Expected Screenshot
      ![image](https://user-images.githubusercontent.com/68696952/115034665.png)
      ### Implementation Screenshot or GIF
      ![Property Intelligence](https://user-images.githubusercontent.com/68696952.gif)
      ### Example Link:
      https://example.atlassian.net/browse/HUB-3874
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
    changelog = ChangelogsService.new(release, commits).changelog
    expect(changelog).to eq(
      {
        version: '1.0.0',
        id: release.id,
        created_at: release.created_at,
        changes: [
          {
            message: 'Create form component',
            references: {
              task_manager: [
                {
                  link: 'https://codelitt.atlassian.net/browse/HUB-2519',
                  type: 'jira',
                  reference_code: 'HUB-2519'
                },
                {
                  link: 'https://example.atlassian.net/browse/HUB-3874',
                  type: 'jira',
                  reference_code: 'HUB-3874'
                }
              ]
            }
          },
          {
            message: 'Create input component',
            references: {
              task_manager: [
                {
                  link: 'https://codelitt.atlassian.net/browse/HUB-2519',
                  type: 'jira',
                  reference_code: 'HUB-2519'
                },
                {
                  link: 'https://example.atlassian.net/browse/HUB-3874',
                  type: 'jira',
                  reference_code: 'HUB-3874'
                }
              ]
            }
          }
        ]
      }
    )
  end

  it 'returns the azure type changelogs' do
    pull_request = FactoryBot.create(
      :pull_request,
      title: 'This is a cool PR',
      repository: repository,
      description: '### Other minor changes:
        - Move files out to a utils file in UploadSection to shorten the file size and improve readability.
      ### Card Link:
      https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1427
      ### Design Expected Screenshot
      ![image](https://user-images.githubusercontent.com/68696952/115034665.png)
      ### Implementation Screenshot or GIF
      ![Property Intelligence](https://user-images.githubusercontent.com/68696952.gif)
      ### Example Link:
      https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1346
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
    changelog = ChangelogsService.new(release, commits).changelog
    expect(changelog).to eq(
      {
        version: '1.0.0',
        id: release.id,
        created_at: release.created_at,
        changes: [
          {
            message: 'Create form component',
            references: {
              task_manager: [
                {
                  link: 'https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1427',
                  type: 'azure',
                  reference_code: '1427'
                },
                {
                  link: 'https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1346',
                  type: 'azure',
                  reference_code: '1346'
                }
              ]
            }
          },
          {
            message: 'Create input component',
            references: {
              task_manager: [
                {
                  link: 'https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1427',
                  type: 'azure',
                  reference_code: '1427'
                },
                {
                  link: 'https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1346',
                  type: 'azure',
                  reference_code: '1346'
                }
              ]
            }
          }
        ]
      }
    )
  end
end

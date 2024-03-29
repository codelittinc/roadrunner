# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangelogsService, type: :service do
  let(:repository) { FactoryBot.create(:repository) }
  let(:release) do
    application = FactoryBot.create(:application, repository:)
    FactoryBot.create(:release, application:, version: '1.0.0')
  end

  it 'returns the jira type changelogs' do
    pull_request = FactoryBot.create(
      :pull_request,
      title: 'This is a cool PR',
      repository:,
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
      pull_request:,
      message: 'Create form component'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request:,
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
      repository:,
      description: '### Other minor changes:
        - Move files out to a utils file in UploadSection to shorten the file size and improve readability.
      ### Card Link:
      https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1427/
      ### Design Expected Screenshot
      ![image](https://user-images.githubusercontent.com/68696952/115034665.png)
      ### Implementation Screenshot or GIF
      ![Property Intelligence](https://user-images.githubusercontent.com/68696952.gif)
      https://dev.azure.com/AY-InnovationCenter/e57bfb9f-c5eb-4f96-9f83-8a98a76bfda4/_apis/git/repositories/93ed8322-6ef9-4c87-a458-b3d0859de666/pullRequests/348/attachments/Screenshot
      ### Example Link:
      https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1346
      ### Notes:
      Still WIP'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request:,
      message: 'Create form component'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request:,
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
                  link: 'https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1427/',
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
                  link: 'https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1427/',
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

  it 'returns the github type changelogs' do
    pull_request = FactoryBot.create(
      :pull_request,
      title: 'This is a cool PR',
      repository:,
      description: '### Other minor changes:
        - Move files out to a utils file in UploadSection to shorten the file size and improve readability.
      ### Card Link:
      https://github.com/codelittinc/roadrunner/issues/315
      ### Design Expected Screenshot
      ![image](https://user-images.github.com/68696952/115034665.png)
      ### Implementation Screenshot or GIF
      ![Property Intelligence](https://user-images.githubusercontent.com/68696952.gif)
      ### Example Link:
      https://github.com/codelittinc/roadrunner/issues/317
      ### Notes:
      Still WIP'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request:,
      message: 'Create form component'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request:,
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
                  link: 'https://github.com/codelittinc/roadrunner/issues/315',
                  type: 'github',
                  reference_code: '315'
                },
                {
                  link: 'https://github.com/codelittinc/roadrunner/issues/317',
                  type: 'github',
                  reference_code: '317'
                }
              ]
            }
          },
          {
            message: 'Create input component',
            references: {
              task_manager: [
                {
                  link: 'https://github.com/codelittinc/roadrunner/issues/315',
                  type: 'github',
                  reference_code: '315'
                },
                {
                  link: 'https://github.com/codelittinc/roadrunner/issues/317',
                  type: 'github',
                  reference_code: '317'
                }
              ]
            }
          }
        ]
      }
    )
  end

  it 'returns the trello type changelogs' do
    pull_request = FactoryBot.create(
      :pull_request,
      title: 'This is a cool PR',
      repository:,
      description: '### Other minor changes:
        - Move files out to a utils file in UploadSection to shorten the file size and improve readability.
      ### Card Link:
      https://trello.com/c/5R38OyDY/855-update-website-sign-up-flow-copy
      ### Design Expected Screenshot
      ![image](https://user-images.github.com/68696952/115034665.png)
      ### Implementation Screenshot or GIF
      ![Property Intelligence](https://user-images.githubusercontent.com/68696952.gif)
      ### Example Link:
      https://trello.com/c/etffBYeE/854-update-auto-trigger-email-copy
      ### Notes:
      Still WIP'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request:,
      message: 'Create form component'
    )
    FactoryBot.create(
      :commit,
      releases: [release],
      pull_request:,
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
                  link: 'https://trello.com/c/5R38OyDY/855-update-website-sign-up-flow-copy',
                  type: 'trello',
                  reference_code: '855-update-website-sign-up-flow-copy'
                },
                {
                  link: 'https://trello.com/c/etffBYeE/854-update-auto-trigger-email-copy',
                  type: 'trello',
                  reference_code: '854-update-auto-trigger-email-copy'
                }
              ]
            }
          },
          {
            message: 'Create input component',
            references: {
              task_manager: [
                {
                  link: 'https://trello.com/c/5R38OyDY/855-update-website-sign-up-flow-copy',
                  type: 'trello',
                  reference_code: '855-update-website-sign-up-flow-copy'
                },
                {
                  link: 'https://trello.com/c/etffBYeE/854-update-auto-trigger-email-copy',
                  type: 'trello',
                  reference_code: '854-update-auto-trigger-email-copy'
                }
              ]
            }
          }
        ]
      }
    )
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReleasesController, type: :controller do
  let(:repository) { FactoryBot.create(:repository) }
  let(:application) { FactoryBot.create(:application, repository: repository) }

  describe '#index' do
    it 'displays the application releases' do
      FactoryBot.create(:release, application: application)
      FactoryBot.create(:release, application: application)
      get :index, format: :json, params: { application_id: application }

      releases_count = JSON.parse(response.body).length
      expect(releases_count).to be(2)
    end

    it 'displays the correct releases informations' do
      release = FactoryBot.create(:release, application: application, version: '3.0.0')
      second_release = FactoryBot.create(:release, application: application, version: '2.0.0')
      pull_request = FactoryBot.create(
        :pull_request,
        title: 'This is a nice PR',
        repository: repository,
        description: '### Other minor changes:
       https://codelitt.atlassian.net/browse/HUB-2519
       ### Design Expected Screenshot
       ![image](https://user-images.githubusercontent.com/68696952/115034665.png)
       ### Implementation Screenshot or GIF'
      )
      FactoryBot.create(
        :commit,
        releases: [release],
        pull_request: pull_request,
        message: 'Create form component'
      )
      FactoryBot.create(
        :commit,
        releases: [second_release],
        pull_request: pull_request,
        message: 'Create input component'
      )

      get :index, format: :json, params: { application_id: application }

      release_creation_time = release.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
      second_release_creation_time = second_release.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ')

      changelog = JSON.parse(response.body)
      expect(changelog).to eq(
        [
          {
            'version' => '3.0.0',
            'id' => release.id,
            'created_at' => release_creation_time,
            'changes' => [
              {
                'message' => 'Create form component',
                'references' => {
                  'task_manager' => [
                    {
                      'link' => 'https://codelitt.atlassian.net/browse/HUB-2519',
                      'type' => 'jira',
                      'reference_code' => 'HUB-2519'
                    }
                  ]
                }
              }
            ]
          },
          {
            'version' => '2.0.0',
            'id' => second_release.id,
            'created_at' => second_release_creation_time,
            'changes' => [
              {
                'message' => 'Create input component',
                'references' => {
                  'task_manager' => [
                    {
                      'link' => 'https://codelitt.atlassian.net/browse/HUB-2519',
                      'type' => 'jira',
                      'reference_code' => 'HUB-2519'
                    }
                  ]
                }
              }
            ]
          }
        ]
      )
    end
  end

  describe '#show' do
    it 'displays the changelog' do
      release = FactoryBot.create(:release, application: application, version: '1.0.0')
      pull_request = FactoryBot.create(
        :pull_request,
        title: 'This is a nice PR',
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

      get :show, format: :json, params: { application_id: application, id: release }

      release_creation_time = release.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
      changelog = JSON.parse(response.body)
      expect(changelog).to eq(
        {
          'version' => '1.0.0',
          'id' => release.id,
          'created_at' => release_creation_time,
          'changes' => [
            {
              'message' => 'Create form component',
              'references' => {
                'task_manager' => [
                  {
                    'link' => 'https://codelitt.atlassian.net/browse/HUB-2519',
                    'type' => 'jira',
                    'reference_code' => 'HUB-2519'
                  },
                  {
                    'link' => 'https://example.atlassian.net/browse/HUB-3874',
                    'type' => 'jira',
                    'reference_code' => 'HUB-3874'
                  }
                ]
              }
            },
            {
              'message' => 'Create input component',
              'references' => {
                'task_manager' => [
                  {
                    'link' => 'https://codelitt.atlassian.net/browse/HUB-2519',
                    'type' => 'jira',
                    'reference_code' => 'HUB-2519'
                  },
                  {
                    'link' => 'https://example.atlassian.net/browse/HUB-3874',
                    'type' => 'jira',
                    'reference_code' => 'HUB-3874'
                  }
                ]
              }
            }
          ]
        }
      )
    end
  end
end

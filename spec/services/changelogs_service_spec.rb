# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangelogsService, type: :service do
  it 'returns the changelog' do
    repository = FactoryBot.create(:repository)
    application = FactoryBot.create(:application, repository: repository)
    release = FactoryBot.create(:release, application: application, version: '1.0.0')
    pull_request = FactoryBot.create(:pull_request, repository: repository)
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

    changelog = ChangelogsService.new(application).changelog
    expect(changelog).to eq(
      {
        version: '1.0.0',
        changes: [
          { message: 'Create form component' },
          { message: 'Create input component' }
        ]
      }
    )
  end
end

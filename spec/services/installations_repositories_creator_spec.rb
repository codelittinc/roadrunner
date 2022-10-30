# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstallationRepositoriesCreator, type: :service do
  let(:subject) do
    installation = FactoryBot.create(:github_installation)
    InstallationRepositoriesCreator.new(installation.id)
  end

  # @TODO: fix Github RSA Key
  xit 'creates the repositories' do
    expect { subject.call }.to change { Repository.count }.by(100)
  end

  # @TODO: fix Github RSA Key
  xit 'does not create a repository when it already exists' do
    FactoryBot.create(:repository, owner: 'codelittinc', name: 'acs-technologies')

    expect { subject.call }.to change { Repository.count }.by(99)
  end
end

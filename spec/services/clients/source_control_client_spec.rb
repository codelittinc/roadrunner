# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clients::SourceControlClient, type: :service do
  context 'when the repository source control type is git' do
    let(:repository) do
      FactoryBot.create(:repository, source_control_type: 'github')
    end

    describe '#list_releases' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::Release).to receive(:list).with(repository)

        Clients::SourceControlClient.new(repository).list_releases
      end
    end

    describe '#create_release' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
          repository, 'v1', 'master', 'cool message', true
        )

        Clients::SourceControlClient.new(repository).create_release('v1', 'master', 'cool message', true)
      end
    end
  end
end

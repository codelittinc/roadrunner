# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clients::SourceControlClient, type: :service do
  context 'when the repository source control type is github' do
    let(:repository) do
      FactoryBot.create(:repository, source_control_type: 'github')
    end

    let(:branch) do
      FactoryBot.create(:branch, repository: repository)
    end

    let(:pull_request) do
      FactoryBot.create(:pull_request, repository: repository)
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
          repository.full_name, 'v1', 'master', 'cool message', true
        )

        Clients::SourceControlClient.new(repository).create_release(
          'v1', 'master', 'cool message', true
        )
      end
    end

    describe '#branch_exists?' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::Branch).to receive(:branch_exists?).with(
          repository, 'my-cool-branch'
        )

        Clients::SourceControlClient.new(repository).branch_exists?('my-cool-branch')
      end
    end

    describe '#get_pull_request' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::PullRequest).to receive(:get).with(
          repository, 1
        )

        Clients::SourceControlClient.new(repository).get_pull_request(1)
      end
    end

    describe '#list_pull_request_commits' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::PullRequest).to receive(:list_commits).with(
          repository, 1
        )

        Clients::SourceControlClient.new(repository).list_pull_request_commits(1)
      end
    end

    describe '#list_branch_commits' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::Branch).to receive(:commits).with(
          repository, branch
        )

        Clients::SourceControlClient.new(repository).list_branch_commits(
          branch
        )
      end
    end

    describe '#compare_commits' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::Branch).to receive(:compare).with(
          repository, pull_request.head, pull_request.base
        )

        Clients::SourceControlClient.new(repository).compare_commits(
          pull_request.head, pull_request.base
        )
      end
    end

    describe '#delete_github_branch' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::Branch).to receive(:delete).with(
          repository, branch
        )

        Clients::SourceControlClient.new(repository).delete_github_branch(branch)
      end
    end

    describe '#list_github_hook' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::Hook).to receive(:list).with(
          repository
        )

        Clients::SourceControlClient.new(repository).list_github_hook
      end
    end

    describe '#create_github_hook' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Github::Hook).to receive(:create).with(repository)

        Clients::SourceControlClient.new(repository).create_github_hook
      end
    end
  end

  context 'when the repository source control type is azure' do
    let(:repository) do
      FactoryBot.create(:repository, source_control_type: 'azure')
    end

    let(:branch) do
      FactoryBot.create(:branch, repository: repository)
    end

    let(:pull_request) do
      FactoryBot.create(:pull_request, repository: repository)
    end

    describe '#list_releases' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Azure::Release).to receive(:list).with(repository)

        Clients::SourceControlClient.new(repository).list_releases
      end
    end

    describe '#branch_exists?' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Azure::Branch).to receive(:branch_exists?).with(
          repository, 'my-cool-branch'
        )

        Clients::SourceControlClient.new(repository).branch_exists?('my-cool-branch')
      end
    end

    describe '#create_release' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Azure::Release).to receive(:create).with(
          repository.full_name, 'v1', 'master', 'cool message', true
        )

        Clients::SourceControlClient.new(repository).create_release(
          'v1', 'master', 'cool message', true
        )
      end
    end

    describe '#get_pull_request' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Azure::PullRequest).to receive(:get).with(
          repository, 1
        )

        Clients::SourceControlClient.new(repository).get_pull_request(1)
      end
    end

    describe '#list_pull_request_commits' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Azure::PullRequest).to receive(:list_commits).with(
          repository, 1
        )

        Clients::SourceControlClient.new(repository).list_pull_request_commits(1)
      end
    end

    describe '#list_branch_commits' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Azure::Branch).to receive(:commits).with(
          repository, branch
        )

        Clients::SourceControlClient.new(repository).list_branch_commits(branch)
      end
    end

    describe '#compare_commits' do
      it 'triggers the correct action' do
        expect_any_instance_of(Clients::Azure::Branch).to receive(:compare).with(
          repository, pull_request.head, pull_request.base
        )

        Clients::SourceControlClient.new(repository).compare_commits(
          pull_request.head, pull_request.base
        )
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Branch, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, name: 'ay-users-api-test', owner: 'Avant')
  end

  describe '#commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('azure#branch#commits') do
        commits = described_class.new.commits(repository, 'master')
        expect(commits.size).to eql(14)
      end
    end

    it 'returns the most recent commit as the first item' do
      repository = FactoryBot.create(:repository, name: 'ay-property-intelligence', owner: 'Avant')

      VCR.use_cassette('github#branch#commits#property-intelligence') do
        commits = described_class.new.commits(repository, 'master')
        expect(commits.first.sha).to eql('e9fbe664bd5e4e9cf2b2026098384eb70cbd86da')
      end
    end
  end

  describe '#compare' do
    context 'when the branches have less than 100 commits' do
      it 'returns the correct commits between two branches' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-repository-test', owner: 'Avant')
        VCR.use_cassette('azure#branch#compare') do
          commits = described_class.new.compare(repository, 'feat/test-compare-branches', 'master')
          expected_commits_sha = %w[
            414274d4df83662810120e71f287997221ff6452
            a3bb66df08ff453d7e28501f268d0fb30540e90a
            73c4a3ea1767614944919c4a96c502f942606516
          ]
          expect(commits.map(&:sha)).to eql(expected_commits_sha)
        end
      end

      it 'returns the correct commits between two tags' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-repository-test', owner: 'Avant')
        VCR.use_cassette('azure#branch#compare') do
          commits = described_class.new.compare(repository, 'v1.0.0', 'rc.1.v1.1.0')
          expected_commits_sha = %w[
            c69a3d840ae27f07cfdcf54eca3fc65a85d3e462
            b0e771a0c2483c4e3802b421ba30d2043bcd28c2
            414274d4df83662810120e71f287997221ff6452
            a3bb66df08ff453d7e28501f268d0fb30540e90a
            73c4a3ea1767614944919c4a96c502f942606516
          ]
          expect(commits.map(&:sha)).to eql(expected_commits_sha)
        end
      end
    end

    context 'when the branches have more than 100 commits' do
      it 'returns the correct commits between two branches' do
        repository = FactoryBot.create(:repository, name: 'ay-property-intelligence', owner: 'Avant')
        VCR.use_cassette('azure#branch#compare#100commits#branches') do
          commits = described_class.new.compare(repository, 'feat/compare-branches-roadrunner', 'master')
          expected_commits_sha = %w[
            f599db662432f5778eaf020ce8db5df7049305a5
            142c5d7fd0ce66e6ccb083c6482682ec9397fc78
            21a228494bb714976a734a4eade26dd2c0e5f044
            28a82194df37ed3e3e259961f6327a01a77ae25d
            64c08b5378ffadc2fce40ef876dad35fbd34c588
            e9fbe664bd5e4e9cf2b2026098384eb70cbd86da
          ]
          expect(commits.map(&:sha)).to eql(expected_commits_sha)
        end
      end

      it 'returns the correct commits between two tags' do
        repository = FactoryBot.create(:repository, name: 'ay-property-intelligence', owner: 'Avant')
        VCR.use_cassette('azure#branch#compare#100#tags') do
          commits = described_class.new.compare(repository, 'rc.1.1.1', 'rc.21.v1.20.0')
          expected_commits_sha = %w[
            142c5d7fd0ce66e6ccb083c6482682ec9397fc78
            21a228494bb714976a734a4eade26dd2c0e5f044
          ]
          expect(commits.map(&:sha)).to eql(expected_commits_sha)
        end
      end

      it 'returns the oldest commit as the first item' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-repository-test', owner: 'Avant')
        VCR.use_cassette('azure#branch#compare#100commits#branches') do
          commits = described_class.new.compare(repository, 'feat/test-compare-branches', 'master')
          expect(commits.first.sha).to eql('414274d4df83662810120e71f287997221ff6452')
        end
      end

      it 'returns the most recent commit as the last item' do
        repository = FactoryBot.create(:repository, name: 'roadrunner-repository-test', owner: 'Avant')
        VCR.use_cassette('azure#branch#compare#100commits#branches') do
          commits = described_class.new.compare(repository, 'feat/test-compare-branches', 'master')
          expect(commits.last.sha).to eql('65a178456d7371ad23691fc30cbfef05a2f74f53')
        end
      end

      context 'comparing tags' do
        it 'returns the oldest commit as the first item' do
          repository = FactoryBot.create(:repository, name: 'roadrunner-repository-test', owner: 'Avant')
          VCR.use_cassette('azure#branch#compare#100commits#branches') do
            commits = described_class.new.compare(repository, 'v1.0.0', 'rc.1.v1.1.0')
            expect(commits.first.sha).to eql('c69a3d840ae27f07cfdcf54eca3fc65a85d3e462')
          end
        end

        it 'returns the most recent commit as the last item' do
          repository = FactoryBot.create(:repository, name: 'roadrunner-repository-test', owner: 'Avant')
          VCR.use_cassette('azure#branch#compare#100commits#branches') do
            commits = described_class.new.compare(repository, 'v1.0.0', 'rc.1.v1.1.0')
            expect(commits.last.sha).to eql('73c4a3ea1767614944919c4a96c502f942606516')
          end
        end
      end
    end
  end

  describe '#branch_exists' do
    it 'returns true when the branch exists' do
      VCR.use_cassette('azure#branch#branch_exists_true') do
        exists = described_class.new.branch_exists?(repository, 'roadrunner/test')
        expect(exists).to be_truthy
      end
    end

    it 'returns true when the branch exists' do
      VCR.use_cassette('azure#branch#branch_exists_false') do
        exists = described_class.new.branch_exists?(repository, 'roadrunner/test1234')
        expect(exists).to be_falsey
      end
    end
  end
end

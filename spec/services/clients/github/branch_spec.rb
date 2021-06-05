# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Branch, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-repository-test')
  end

  describe '#commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('github#branch#commits') do
        commits = described_class.new.commits(repository, 'master')
        expect(commits.map(&:sha)).to eql(%w[
                                            5a5a700acd4e7b99a9cab7ac399b48961edf9a11
                                            d8f5dc5a6fbddb85455bf213dbdd97d0ef9e4137
                                            f6e390ce82c76adb083a80d93620a0d0cdd02fc5
                                            814fe38412a995246723d5a759d323f5310e29f1
                                            a42574036ea3f3c3a5b6d77d24d88ede0d6aee9d
                                            e19189dfaf8b628eaa64b6ebaa56e0f88a150c30
                                            ec6d8514475be4eea67446e02365f479a789a5d4
                                            282463d2ff3fcb10a1095b33bdf1ff5fd99d1d40
                                            8b261a600cbf6a259730f6cf472b73d1d8cdbcc9
                                          ])
      end
    end

    it 'returns the most recent commit as the first item' do
      VCR.use_cassette('github#branch#commits') do
        commits = described_class.new.commits(repository, 'master')
        expect(commits.first.sha).to eql('5a5a700acd4e7b99a9cab7ac399b48961edf9a11')
      end
    end

    it 'returns the oldest commit as the last item' do
      VCR.use_cassette('github#branch#commits') do
        commits = described_class.new.commits(repository, 'master')
        expect(commits.last.sha).to eql('8b261a600cbf6a259730f6cf472b73d1d8cdbcc9')
      end
    end
  end

  describe '#compare' do
    it 'returns a list the commits difference between two branches' do
      VCR.use_cassette('github#branch#compare') do
        commits = described_class.new.compare(repository, 'feat/compare-branches', 'master')
        expect(commits.size).to eql(3)
      end
    end

    it 'returns the oldest commit as the first item' do
      VCR.use_cassette('github#branch#commits') do
        commits = described_class.new.compare(repository, 'feat/compare-branches', 'master')
        expect(commits.first.sha).to eql('f6e390ce82c76adb083a80d93620a0d0cdd02fc5')
      end
    end

    it 'returns the most recent commit as the last item' do
      VCR.use_cassette('github#branch#compare') do
        commits = described_class.new.compare(repository, 'feat/compare-branches', 'master')
        expect(commits.last.sha).to eql('5a5a700acd4e7b99a9cab7ac399b48961edf9a11')
      end
    end
  end
end

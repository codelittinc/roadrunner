# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Versioning::Sorter, type: :service do
  describe 'sort' do
    context 'with invalid item types' do
      it 'places the invalid items at the end of the list' do
        list = ['v1.15.0', 'v1.19.0', 'test-1', 'v0.0.5-rc0', 'v1.9.0']
        sorter = Versioning::Sorter.new(list)
        expect(sorter.sort).to eql(['v1.19.0', 'v1.15.0', 'v1.9.0', 'test-1', 'v0.0.5-rc0'])
      end
    end

    context 'with different item types' do
      it 'sorts and returns a list of strings' do
        list = ['v1.15.0', 'v1.19.0', 'v1.9.0']
        sorter = Versioning::Sorter.new(list)
        expect(sorter.sort).to eql(['v1.19.0', 'v1.15.0', 'v1.9.0'])
      end
    end

    it 'sorts and returns a list of release parsers' do
      list = [
        Clients::Azure::Parsers::ReleaseParser.new({ name: 'v1.15.0' }),
        Clients::Azure::Parsers::ReleaseParser.new({ name: 'v1.9.0' }),
        Clients::Azure::Parsers::ReleaseParser.new({ name: 'v1.19.0' })
      ]

      sorter = Versioning::Sorter.new(list)
      expect(sorter.sort.map(&:tag_name)).to eql(['v1.19.0', 'v1.15.0', 'v1.9.0'])
    end
  end

  context 'with valid item types' do
    it 'sorts correctly when there are releases and release candidates' do
      list = ['v1.15.0', 'rc.1.v1.15.0', 'v1.19.0', 'v1.9.0', 'v1.16.0', 'rc.1.v1.16.0']

      sorter = Versioning::Sorter.new(list)
      expect(sorter.sort).to eql([
                                   'v1.19.0',
                                   'v1.16.0',
                                   'rc.1.v1.16.0',
                                   'v1.15.0',
                                   'rc.1.v1.15.0',
                                   'v1.9.0'
                                 ])
    end

    it 'sorts release candidates properly' do
      list = [
        'rc.9.v1.20.0',
        'rc.20.v1.20.0',
        'rc.19.v1.20.0',
        'rc.1.v1.20.0'
      ]

      sorter = Versioning::Sorter.new(list)
      expect(sorter.sort).to eql([
                                   'rc.20.v1.20.0',
                                   'rc.19.v1.20.0',
                                   'rc.9.v1.20.0',
                                   'rc.1.v1.20.0'
                                 ])
    end

    it 'sorts correctly when there are releases, release candidates and hotfixes' do
      list = ['v1.15.0', 'v1.16.2', 'rc.1.v1.15.0', 'v1.16.1', 'v1.19.0', 'v1.9.0', 'v1.16.0', 'rc.1.v1.16.0']

      sorter = Versioning::Sorter.new(list)
      expect(sorter.sort).to eql([
                                   'v1.19.0',
                                   'v1.16.2',
                                   'v1.16.1',
                                   'v1.16.0',
                                   'rc.1.v1.16.0',
                                   'v1.15.0',
                                   'rc.1.v1.15.0',
                                   'v1.9.0'
                                 ])
    end
  end
end

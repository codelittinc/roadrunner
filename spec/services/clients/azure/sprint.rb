# frozen_string_literal: true

require 'rails_helper'
# require 'external_api_helper'

RSpec.describe Clients::Azure::Sprint, type: :service do
  describe '#list' do
    it 'returns a list of sprints' do
      VCR.use_cassette('azure#sprint#list') do
        sprints = described_class.new.list('Visualization')
        expect(sprints.size).to eql(11)
      end
    end

    it 'returns a list of sprint objects' do
      VCR.use_cassette('azure#sprint#list') do
        sprints = described_class.new.list('Visualization')
        expect(sprints.first).to be_a(Clients::Azure::Parsers::SprintParser)
      end
    end

    context 'when given a time_frame' do
      it 'only returns sprints in that given time_frame' do
        VCR.use_cassette('azure#sprint#list') do
          sprints = described_class.new.list('Visualization', 'past')
          sprints.each do |sprint|
            expect(sprint.time_frame).to be('past')
          end
        end
      end
    end
  end
  describe '#work_items' do
    it 'returns a list of work items' do
      VCR.use_cassette('azure#sprint#work_items') do
        work_items = described_class.new.work_items('Visualization', '646f9f98-4023-4b4a-927b-85ddcfe19414')
        expect(work_items.size).to eql(25)
      end
    end

    it 'returns a list of work items objects' do
      VCR.use_cassette('azure#sprint#work_items') do
        work_items = described_class.new.work_items('Visualization', '646f9f98-4023-4b4a-927b-85ddcfe19414')
        expect(work_items.first).to be_a(Clients::Azure::Parsers::WorkItemParser)
      end
    end
  end
end

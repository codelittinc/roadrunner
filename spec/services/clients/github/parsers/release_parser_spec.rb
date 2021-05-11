# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Clients::Github::Parsers::ReleaseParser, type: :service do
  let(:valid_json) { load_fixture('github_release.json') }
  let(:release) { described_class.new(valid_json) }

  describe '#parser' do
    it 'returns a release object' do
      expect(release).not_to be_nil
    end

    it 'returns the tag_name' do
      expect(release.tag_name).to eql('rc.1.v1.1.1')
    end

    it 'returns the url' do
      expect(release.url).to eql('https://api.github.com/repos/codelittinc/roadrunner-repository-test/releases/32508880')
    end
  end
end

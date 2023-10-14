# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Backstage::User, type: :service do
  describe '#show' do
    context 'with a valid id' do
      it 'returns the user' do
        VCR.use_cassette('clients#backstage#clients#list') do
          users = described_class.new.list(%w[azure-devops-kaio rony-azure-devops])
          expect(users.map(&:email)).to eq(['kaio@codelitt.com', 'rheniery.mendes@codelitt.com'])
        end
      end

      it 'returns a user that has a slack attribute' do
        VCR.use_cassette('clients#backstage#clients#list') do
          users = described_class.new.list(%w[azure-devops-kaio rony-azure-devops])
          expect(users.map(&:slack)).to eq(['kaiomagalhaes', nil])
        end
      end
    end
  end
end

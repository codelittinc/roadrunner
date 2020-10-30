# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id                    :bigint           not null, primary key
#  link                  :string
#  supports_health_check :boolean
#  repository_id         :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  external_identifier   :string
#  active                :boolean          default(TRUE)
#  environment           :string
#  name                  :string
#
require 'rails_helper'

RSpec.describe Server, type: :model do
  describe 'associations' do
    it { should belong_to(:repository) }
  end

  describe 'validations' do
    it { should validate_presence_of(:link) }
    it { should validate_presence_of(:repository) }
  end

  describe 'status' do
    context 'when there are health check without incidents' do
      it 'returns normal' do
        server = FactoryBot.create(:server)

        FactoryBot.create(:server_status_check, server: server)
        expect(server.reload.status).to eql('normal')
      end
    end

    context 'when there is a health check and a server incident' do
      it 'returns unstable' do
        server = FactoryBot.create(:server)
        FactoryBot.create(:server_incident, server: server)
        FactoryBot.create(:server_status_check, server: server)
        expect(server.reload.status).to eql('unstable')
      end
    end

    context 'when there is a health check incident' do
      it 'returns unavailable' do
        server = FactoryBot.create(:server)
        FactoryBot.create(:server_status_check, server: server, code: 500)

        expect(server.reload.status).to eql('unavailable')
      end
    end

    context 'when there is no health check and server incident' do
      it 'returns data unavailable' do
        server = FactoryBot.create(:server)

        expect(server.reload.status).to eql('data unavailable')
      end
    end
  end
end

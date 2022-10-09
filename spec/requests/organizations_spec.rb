# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/organizations', type: :request do
  let(:valid_attributes) do
    {
      notifications_id: '123',
      name: 'Ideas to bits',
      notifications_key: 'my-cool-key'
    }
  end

  let(:invalid_attributes) do
    {
      notifications_id: nil,
      name: 'Ideas to bits',
      notifications_key: 'my-cool-key'
    }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Organization.create! valid_attributes
      get organizations_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      organization = Organization.create! valid_attributes
      get organization_url(organization)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Organization' do
        expect do
          post organizations_url, params: { organization: valid_attributes }
        end.to change(Organization, :count).by(1)
      end
    end

    context 'with a recurring organization' do
      it 'does not create a new Organization' do
        post organizations_url, params: { organization: valid_attributes }

        expect do
          post organizations_url, params: { organization: valid_attributes }
        end.to change(Organization, :count).by(0)
      end

      it 'updates the old Organization' do
        org = Organization.create(valid_attributes)

        post organizations_url, params: { organization:
        { name: 'Codelitt',
          notifications_key: valid_attributes[:notifications_key],
          notifications_id: valid_attributes[:notifications_id] } }

        org.reload
        expect(org.name).to eq('Codelitt')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Organization' do
        expect do
          post organizations_url, params: { organization: invalid_attributes }
        end.to change(Organization, :count).by(0)
      end
    end
  end
end

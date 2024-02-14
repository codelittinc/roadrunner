# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/pull_requests', type: :request do
  describe 'GET /index' do
    context 'with a project_id filter' do
      it 'only returns the pull requests of that project' do
        repository1 = FactoryBot.create(:repository, external_project_id: 2)
        repository2 = FactoryBot.create(:repository, external_project_id: 3)
        FactoryBot.create(:pull_request, backstage_user_id: 1, state: 'merged', repository: repository1,
                                         source_control_id: 1)
        FactoryBot.create(:pull_request, backstage_user_id: 1, state: 'cancelled', repository: repository1,
                                         source_control_id: 2)
        FactoryBot.create(:pull_request, backstage_user_id: 2, state: 'merged', repository: repository1,
                                         source_control_id: 3)
        FactoryBot.create(:pull_request, backstage_user_id: 1, state: 'merged', repository: repository2,
                                         source_control_id: 1)

        get "#{pull_requests_url}.json", params: {
          user_id: 1,
          state: 'merged',
          project_id: 2,
          start_date: Date.yesterday,
          end_date: Date.tomorrow
        }
        expect(response.parsed_body.size).to eql(1)
      end
    end

    context 'without a project_id filter' do
      it 'returns all projects of a user' do
        repository1 = FactoryBot.create(:repository, external_project_id: 2)
        repository2 = FactoryBot.create(:repository, external_project_id: 3)
        FactoryBot.create(:pull_request, backstage_user_id: 1, state: 'merged', repository: repository1,
                                         source_control_id: 1)
        FactoryBot.create(:pull_request, backstage_user_id: 1, state: 'cancelled', repository: repository1,
                                         source_control_id: 2)
        FactoryBot.create(:pull_request, backstage_user_id: 2, state: 'merged', repository: repository1,
                                         source_control_id: 3)
        FactoryBot.create(:pull_request, backstage_user_id: 1, state: 'merged', repository: repository2,
                                         source_control_id: 1)

        get "#{pull_requests_url}.json", params: {
          backstage_user_id: 1,
          state: 'merged',
          start_date: Date.yesterday,
          end_date: Date.tomorrow

        }
        expect(response.parsed_body.size).to eql(3)
      end
    end
  end
end

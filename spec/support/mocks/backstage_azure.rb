# frozen_string_literal: true

RSpec.shared_context 'mock backstage azure', shared_context: :metadata do
  before do
    mock_external_project = OpenStruct.new(
      metadata: { 'azure_project_name' => 'Avant', 'azure_owner' => 'AY-InnovationCenter' },
      customer: OpenStruct.new(github_api_key: '123456')
    )

    allow_any_instance_of(Repository).to receive(:external_project).and_return(mock_external_project)
  end
end

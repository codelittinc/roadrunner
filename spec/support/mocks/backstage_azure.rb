# frozen_string_literal: true

RSpec.shared_context 'mock backstage azure', shared_context: :metadata do
  before do
    mock_external_project = OpenStruct.new(
      customer: OpenStruct.new(metadata: { 'azure_project_name' => 'Avant', 'azure_owner' => 'AY-InnovationCenter' })
    )

    allow_any_instance_of(Repository).to receive(:external_project).and_return(mock_external_project)
  end
end

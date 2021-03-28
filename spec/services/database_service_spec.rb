# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseService, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'backup_restore_db.json'))).with_indifferent_access
  end

  describe '#backup_restore_db' do
    context 'with a valid json' do
      # @TODO: mock the database connection
      xit 'returns a success message' do
        output = described_class.new.backup_restore_db(valid_json)

        expect(output).to be == 'Command executed with success!'
      end
    end

    context 'with a invalid json' do
      it 'returns a fail message' do
        invalid_json = valid_json.deep_dup

        invalid_json['source_host'] = 'to_fail'
        output = described_class.new.backup_restore_db(invalid_json)

        expect(output).to be == 'Command failed'
      end
    end
  end
end

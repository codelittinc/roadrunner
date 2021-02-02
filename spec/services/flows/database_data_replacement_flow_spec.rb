# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::DatabaseDataReplacementFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'database_replacement.json'))).with_indifferent_access
  end

  describe '#flow?' do
    before(:each) do
      from_database = FactoryBot.create(:database_credential)
      to_database = FactoryBot.create(:database_credential, env: 'qa', name: 'roadrunner qa', db_host: 'test')

      valid_json[:from][:id] = from_database.id
      valid_json[:to][:id] = to_database.id
    end

    context 'returns true when' do
      it 'the database destination env is not prod' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end

      it 'there is the destination database' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end

      it 'there is the source database' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'the database destination env is prod' do
        invalid_json = valid_json.deep_dup

        invalid_json[:to][:env] = 'prod'
        flow = described_class.new(invalid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'there is the destination database' do
        invalid_json = valid_json.deep_dup

        invalid_json[:to][:id] = 280
        flow = described_class.new(invalid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'there is the source database' do
        invalid_json = valid_json.deep_dup

        invalid_json[:from][:id] = 15
        flow = described_class.new(invalid_json)
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    it 'returns a success message with a valid json' do
      from_database = FactoryBot.create(:database_credential, env: 'dev', name: 'roadrunner dev', db_host: 'ec2-34-234-228-127.compute-1.amazonaws.com',
                                                              db_name: 'd2elqpp67avkpp',
                                                              db_user: 'tbqumaljebeeoq',
                                                              db_password: 'f0b24ee94d6804aa5ac275071417776f7ddd4429ab1e8e32a1f44ea117f67ea4')

      to_database = FactoryBot.create(:database_credential, env: 'qa', name: 'roadrunner qa',
                                                            db_host: 'ec2-34-236-215-156.compute-1.amazonaws.com',
                                                            db_name: 'd3ls4uhlfv7gd4',
                                                            db_user: 'vhmemprvkdjwse',
                                                            db_password: '9e3ef1c15cb505a828e293247ccb2afcf07ca6e8c3400aad1c7620fbe68b94fc')
      valid_json[:from][:id] = from_database.id
      valid_json[:to][:id] = to_database.id
      flow = described_class.new(valid_json)

      expected_json_param =
        {
          "filename": 'backup',
          "source_host": from_database.db_host,
          "source_database": from_database.db_name,
          "source_user": from_database.db_user,
          "source_password": from_database.db_password,
          "destination_host": to_database.db_host,
          "destination_database": to_database.db_name,
          "destination_user": to_database.db_user,
          "destination_password": to_database.db_password
        }

      expect_any_instance_of(DatabaseService).to receive(:backup_restore_db).with(expected_json_param, true).and_return('Command executed with success!')

      flow.execute
    end
  end
end

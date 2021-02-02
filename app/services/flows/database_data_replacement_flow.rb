# frozen_string_literal: true

module Flows
  class DatabaseDataReplacementFlow < BaseFlow
    def execute
      backup_restore_json =
        {
          "filename": 'backup',
          "source_host": from_database_credential.db_host,
          "source_database": from_database_credential.db_name,
          "source_user": from_database_credential.db_user,
          "source_password": from_database_credential.db_password,
          "destination_host": to_database_credential.db_host,
          "destination_database": to_database_credential.db_name,
          "destination_user": to_database_credential.db_user,
          "destination_password": to_database_credential.db_password
        }

      DatabaseService.new.backup_restore_db(backup_restore_json, true)
    end

    def flow?
      return false unless from_database
      return false unless to_database
      return false unless from_database_credential
      return false unless to_database_credential
      return false if to_database['env'] == DatabaseCredential::PROD_ENV

      true
    end

    private

    def from_database
      @from_database = @params[:from]
    end

    def to_database
      @to_database = @params[:to]
    end

    def from_database_credential
      @from_database_credential ||= DatabaseCredential.find_by(env: from_database[:env], name: from_database[:name], id: from_database[:id])
    end

    def to_database_credential
      @to_database_credential ||= DatabaseCredential.find_by(env: to_database[:env], name: to_database[:name], id: to_database[:id])
    end
  end
end

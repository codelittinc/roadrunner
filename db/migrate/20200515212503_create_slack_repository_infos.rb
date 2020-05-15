class CreateSlackRepositoryInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :slack_repository_infos do |t|
      t.string :deploy_channel
      t.references :repository, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class AddSlackFeedChannelToSlackRepositoryInfo < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_repository_infos, :feed_channel, :string
  end
end

# frozen_string_literal: true

class AddChannelFeedToSlackRepositoryInfo < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_repository_infos, :feed_channel, :string
  end
end

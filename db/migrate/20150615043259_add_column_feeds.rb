class AddColumnFeeds < ActiveRecord::Migration
  def change
  	add_column :feeds, :title, :string
  	add_column :feeds, :link, :string
  	add_column :feeds, :entrydate, :string
  end
end

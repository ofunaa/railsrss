class AddColumnToFeeds < ActiveRecord::Migration
  def change
  	add_column :feeds, :desc, :string
  	add_column :feeds, :category, :string
  end
end

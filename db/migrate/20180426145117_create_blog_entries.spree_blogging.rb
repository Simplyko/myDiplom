# This migration comes from spree_blogging (originally 20081004123517)
class CreateBlogEntries < ActiveRecord::Migration[4.2]
  def self.up
    create_table :spree_blogging_entries do |t|
      t.column :title, :string
      t.column :body, :text
      t.column :permalink, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :spree_blogging_entries
  end
end

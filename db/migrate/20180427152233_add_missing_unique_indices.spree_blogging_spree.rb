# This migration comes from spree_blogging_spree (originally 20140901055150)
class AddMissingUniqueIndices < ActiveRecord::Migration[5.1]
  def self.up
    add_index :tags, :name, unique: true

    remove_index :taggings, :tag_id
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :taggings,
      [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
      unique: true, name: 'taggings_idx'
   end

  def self.down
    remove_index :tags, :name

    remove_index :taggings, name: 'taggings_idx'
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end
end

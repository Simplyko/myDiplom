# This migration comes from spree_blogging (originally 20140901055150)
class AddMissingUniqueIndices < ActiveRecord::Migration[4.2]
  def self.up
    add_index :blog_tags, :name, unique: true

    remove_index :taggings, :tag_id
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :blog_taggings,
      [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
      unique: true, name: 'blog_taggings_idx'
   end

  def self.down
    remove_index :blog_tags, :name

    remove_index :blog_taggings, name: 'blog_taggings_idx'
    add_index :blog_taggings, :tag_id
    add_index :blog_taggings, [:taggable_id, :taggable_type, :context]
  end
end

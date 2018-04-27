# This migration comes from spree_blogging_spree (originally 20150213140632)
require 'acts-as-taggable-on'

class AddTaggingsCounterCacheToTags < ActiveRecord::Migration[5.1]
  def self.up
    add_column :tags, :taggings_count, :integer, default: 0

    ActsAsTaggableOn::Tag.reset_column_information
    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end
  end

  def self.down
    remove_column :tags, :taggings_count
  end
end

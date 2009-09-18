class CreateTagsTimeEntries < ActiveRecord::Migration
  def self.up
      create_table :tags_time_entries, :id => false do |t|
      t.references :time_entry
      t.references :tag
      t.timestamps
    end
  end

  def self.down
    drop_table :tags_time_entries
  end
end

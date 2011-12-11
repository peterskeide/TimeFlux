class IncreaseLengthOfTimeEntriesNotes < ActiveRecord::Migration
  def self.up
    change_column :time_entries, :notes, :string, :limit => 500
  end

  def self.down
    change_column :time_entries, :notes, :string, :limit => 255
  end
end

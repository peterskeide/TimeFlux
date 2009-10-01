class AddIndexOnTimeEntries < ActiveRecord::Migration
  def self.up
    add_index(:time_entries, :date)
    add_index(:time_entries, :user_id)
  end

  def self.down
    remove_index(:time_entries, :date)
    remove_index(:time_entries, :user_id)
  end
end

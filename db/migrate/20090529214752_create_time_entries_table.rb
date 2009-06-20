class CreateTimeEntriesTable < ActiveRecord::Migration
  def self.up
    create_table :time_entries do |t|
      t.float :hours, :default => 0.0
      t.boolean :billed, :default => false
      t.boolean :locked, :default => false
      t.boolean :counterpost, :default => false
      t.integer :month
      t.string :notes
      t.date :date, :null => false
      t.references :week_entry
      t.timestamps
    end
  end

  def self.down
    drop_table :time_entries
  end
end

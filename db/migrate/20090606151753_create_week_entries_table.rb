class CreateWeekEntriesTable < ActiveRecord::Migration
  def self.up
    create_table :week_entries do |t|
      t.boolean :locked
      t.integer :year
      t.integer :week_number
      t.references :person
      t.references :activity
      t.timestamps
    end
  end

  def self.down
    drop_table :week_entries
  end
end

class CreateHolidays < ActiveRecord::Migration
  def self.up
    create_table :holidays do |t|
      t.date :date
      t.boolean :repeat
      t.string :note
      t.float :working_hours
      t.timestamps
    end
  end

  def self.down
    drop_table :holidays
  end
end

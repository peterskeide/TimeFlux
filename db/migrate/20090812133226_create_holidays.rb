class CreateHolidays < ActiveRecord::Migration
  def self.up
    create_table :holidays do |t|
      t.date :date
      t.string :note
      t.boolean :repeat
      t.float :working_hours
      t.timestamps
    end
  end

  def self.down
    drop_table :holidays
  end
end

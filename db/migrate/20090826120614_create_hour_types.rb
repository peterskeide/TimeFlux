class CreateHourTypes < ActiveRecord::Migration
  def self.up
    create_table :hour_types do |t|
      t.string :name
      t.boolean :default_hour_type

      t.timestamps
    end
  end

  def self.down
    drop_table :hour_types
  end
end

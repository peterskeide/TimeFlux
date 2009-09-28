class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :time_zone
      t.float :work_hours
      t.integer :activity_id
      t.timestamps
    end
  end

  def self.down
    drop_table :configurations
  end
end

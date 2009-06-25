class CreateActivitiesTable < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :name
      t.string :description
      t.boolean :active
      t.boolean :default_activity
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end

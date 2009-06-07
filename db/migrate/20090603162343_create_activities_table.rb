class CreateActivitiesTable < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :name
      t.string :description
      t.boolean :active
      t.references :category
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end

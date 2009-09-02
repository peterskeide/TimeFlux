class CreateActivitiesTable < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :name,              :null => false
      t.string :description
      t.references :project
      t.boolean :active,           :default => true
      t.boolean :default_activity, :default => false
      t.boolean :shared,           :default => false
      t.boolean :template,         :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end

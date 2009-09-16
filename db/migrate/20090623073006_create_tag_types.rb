class CreateTagTypes < ActiveRecord::Migration
  def self.up
    create_table :tag_types do |t|
      t.string :name
      t.string :icon
      t.boolean :mutually_exclusive, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :tag_types
  end
end

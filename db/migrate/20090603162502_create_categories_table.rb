class CreateCategoriesTable < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.string :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end

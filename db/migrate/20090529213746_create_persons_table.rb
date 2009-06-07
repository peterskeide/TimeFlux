class CreatePersonsTable < ActiveRecord::Migration
  def self.up
    create_table :persons do |t|
      t.string :firstname
      t.string :lastname
      t.string :username
      t.string :password
      t.string :email
      t.string :operative_status
      t.timestamps
    end
  end

  def self.down
    drop_table :persons
  end
end

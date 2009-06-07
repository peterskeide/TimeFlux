class CreateUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
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
    drop_table :users
  end
end

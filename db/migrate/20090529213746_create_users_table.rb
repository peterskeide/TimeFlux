class CreateUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :firstname, :null => false
      t.string :lastname, :null => false
      t.string :login, :null => false 
      t.string :email, :null => false 
      t.string :crypted_password, :null => false 
      t.string :password_salt, :null => false 
      t.string :persistence_token, :null => false 
      t.string :operative_status
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

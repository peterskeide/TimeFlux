class CreateActivitiesUsersTable < ActiveRecord::Migration
  def self.up
    create_table :activities_users, :id => false do |t|
      t.references :activity
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :activities_users
  end
end

class AddDepartmentToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :department_id, :integer
  end

  def self.down
    remove_column :users, :department_id
  end
end

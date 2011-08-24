class AddDepartmentToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :department_id, :integer, :default => Department.first ? Department.first.id : nil
    change_column :projects, :comment, :string,  :length => 1024
  end

  def self.down
     remove_column :projects, :department_id
  end
end

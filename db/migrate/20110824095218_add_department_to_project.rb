class AddDepartmentToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :department_id, :integer
    change_column :projects, :comment, :string,  :length => 1024

    department = Department.first
    if department
      projects = Project.all
      projects.each{|p| p.department_id = department.id}
      projects.each{|p| p.save}
    end
  end

  def self.down
     remove_column :projects, :department_id
  end
end

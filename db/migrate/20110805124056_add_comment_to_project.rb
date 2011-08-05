class AddCommentToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :comment, :string
  end

  def self.down
    remove_column :projects, :comment
  end
end

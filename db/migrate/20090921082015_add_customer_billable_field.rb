class AddCustomerBillableField < ActiveRecord::Migration
  def self.up
    add_column :customers, :billable, :boolean, :default => true
  end

  def self.down
    remove_column :customers, :billable
  end
end

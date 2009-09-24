class ReplaceLockedAndBilledFieldsInTimeEntryWithStatus < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :status, :integer, :default => 0
    
    TimeEntry.all.each do |te|
      if te.billed
        te.status = 2
        te.save
      elsif te.locked
        te.status = 1
        te.save;
      end
    end
    
    remove_column :time_entries, :locked
    remove_column :time_entries, :billed
  end

  def self.down
    add_column :time_entries, :locked, :boolean
    add_column :time_entries, :billed, :boolean
    
    TimeEntry.all.each do |te|
      case te.status
        when 1 then te.locked = true; te.save
      when 2 then te.locked = true; te.billed = true; te.save;
      end
    end
    
    remove_column :time_entries, :status
  end
end

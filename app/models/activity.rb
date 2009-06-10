class Activity < ActiveRecord::Base
  
  belongs_to :category
  has_many :week_entries
  has_many :time_entries, :through => :week_entries

  def after_destroy
    raise "#{self.name} has registered hours - could not be removed" if has_time_entries?
  end

  def has_time_entries?
    self.week_entries.size > 0
    #self.time_entries.size > 0
  end
end
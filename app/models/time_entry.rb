class TimeEntry < ActiveRecord::Base
      
  belongs_to :week_entry
  
  validates_format_of :hours, :with => /^[\d|.|,]*$/

  acts_as_reportable
  
  named_scope :for_month, lambda { |month|
    { :conditions => { :month => month } } 
  }
    
  named_scope :for_activity, lambda { |activity_id|
     { :joins => :week_entry, :conditions => ['week_entries.activity_id = ?', activity_id] }
  }
  
  def <=>(other)
    date <=> other.date
  end
    
end
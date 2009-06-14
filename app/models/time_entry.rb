class TimeEntry < ActiveRecord::Base
      
  belongs_to :week_entry
  
  validates_format_of :hours, :with => /^[\d|.|,]*$/

  acts_as_reportable
  
  def <=>(other)
    date <=> other.date
  end
    
end
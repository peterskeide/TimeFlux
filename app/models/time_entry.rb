class TimeEntry < ActiveRecord::Base
      
  belongs_to :week_entry 
  
  validates_numericality_of :hours
  
  def <=>(other)
    date <=> other.date
  end
    
end
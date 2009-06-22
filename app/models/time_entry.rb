class TimeEntry < ActiveRecord::Base
      
  belongs_to :user
  belongs_to :activity
  
  validates_format_of :hours, :with => /^[\d|.|,]*$/

  acts_as_reportable
  
  named_scope :between, lambda { |*args|
      {  :conditions => ['date between ? and ?', (args.first || Time.now), (args.second || 7.days.ago )] }
    }
      
  named_scope :for_activity, lambda { |activity_id|
     { :conditions => { :activity_id => activity_id } }
  }
  
  def <=>(other)
    date <=> other.date
  end
    
end
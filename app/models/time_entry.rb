class TimeEntry < ActiveRecord::Base
      
  belongs_to :week_entry
  
  validates_format_of :hours, :with => /^[\d|.|,]*$/
  
  def <=>(other)
    date <=> other.date
  end

  def self.find_in_month (year, month)
    start_of_month = Time.mktime(year.to_i, month.to_i, 1)
    conditions = ['date between ? and ?', start_of_month, start_of_month.end_of_month]
    self.find(:all, :conditions => conditions)
  end

  named_scope :between, lambda { |*args|
    {  :conditions => ['date between ? and ?',  (args.first || Time.now), (args.second || 7.days.ago )] }
  }

  named_scope :for_user, lambda { |user_id|
     { :joins => :week_entry, :conditions => ['week_entries.user_id = ?', user_id] }
  }

  named_scope :for_activity, lambda { |activity_id|
     { :joins => :week_entry, :conditions => ['week_entries.activity_id = ?', activity_id] }
  }


  def to_s
    "#{self.hours} hours on date #{self.date}"
  end

    
end
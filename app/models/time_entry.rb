class TimeEntry < ActiveRecord::Base
      
  belongs_to :user
  belongs_to :activity
  
  validates_format_of :hours, :with => /^[\d|.|,]*$/
  validate_on_update :must_not_be_locked
  
  named_scope :between, lambda { |*args|
    {  :conditions => ['date between ? and ?', (args.first || Time.now), (args.second || 7.days.ago )] }
  }
      
  named_scope :for_activity, lambda { |activity_id|
    { :conditions => { :activity_id => activity_id } }
  }
  
  def <=>(other)
    date <=> other.date
  end

  def self.find_in_month (year, month)
    start_of_month = Time.mktime(year.to_i, month.to_i, 1)
    conditions = ['date between ? and ?', start_of_month, start_of_month.end_of_month]
    self.find(:all, :conditions => conditions)
  end

  def to_s
    "#{self.hours} hours on date #{self.date}"
  end 
  
  private
  
  def must_not_be_locked
    if changed?
      errors.add_to_base("Updating locked time entries is not possible") if locked
    end
  end
    
end
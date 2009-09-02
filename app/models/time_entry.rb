class TimeEntry < ActiveRecord::Base

  def before_destroy
    errors.add_to_base "Cannot delete locked hours"; return false if locked
  end

  belongs_to :user
  belongs_to :activity
  belongs_to :hour_type
  
  #validates_numericality_of :hours, :greater_than_or_equal_to => -24.0, :less_than_or_equal_to => 24.0
  validates_numericality_of :hours, :greater_than => 0.0, :less_than_or_equal_to => 24.0
  
  #validates_format_of :hours, :with => /^[\d|.|,]*$/

  named_scope :on_day, lambda { |day|
    {  :conditions => ['date = ?', day ] }
  }

  named_scope :for_user, lambda { |user_id|
    { :conditions => { :user_id => user_id } }
  }

  named_scope :billed, lambda { |billed|
    { :conditions => { :billed => billed } }
  }

  named_scope :between, lambda { |*args|
    {  :conditions => ['date between ? and ?', args.first, args.second] }
  }

  named_scope :for_activity, lambda { |*activity_ids|
    {  :conditions =>  ["activity_id IN (?)", activity_ids ] }
  }

  named_scope :for_project, lambda { |project_id|
    { :include => :activity, :conditions => ["activities.project_id = ?", project_id] }
  }

  named_scope :distinct_dates, :select => 'DISTINCT date'

  named_scope :distinct_activities, :select => 'DISTINCT activity_id'
  
  def weekday
    Date::DAYNAMES[date.wday]
  end
  
  def self.search(from_date, to_date, activities=nil, user=nil, billed=nil)
    search = ["TimeEntry"]
    search << "for_activity(#{activities.collect { |a| a.id }.join(',')})" unless activities.blank?
    search << "for_user(#{user.id})" unless user.blank?
    search << "billed(#{billed})" unless billed.blank?
    query = search.join(".")

    logger.debug("Time entry Search Query: #{query}")
    (eval query).between(from_date,to_date)
  end

  def self.mark_as_locked(time_entries, value=true)
    time_entries.each do |t|
      t.locked = value
      t.save
    end
  end

  # Billed time entries are always locked
  def self.mark_as_billed(time_entries, value=true)
    time_entries.each do |t|
      t.billed = value
      t.locked = true if value
      t.save
    end
  end
  
  def <=>(other)
    date <=> other.date
  end

  def to_s
    "#{self.hours} hours on date #{self.date}"
  end

  def hours_to_s
    if self.hours > 0 then self.hours.to_s else '-' end
  end
  
  def self.sum_hours_for_user_and_date(user_id, date = Date.today)
    TimeEntry.sum("hours", :conditions => 
      [ "user_id = :user_id AND date = :date", 
      { :user_id => user_id, :date => date } ])
  end

  private


end
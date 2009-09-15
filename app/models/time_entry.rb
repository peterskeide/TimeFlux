class TimeEntry < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :activity
  belongs_to :hour_type
  
  validates_numericality_of :hours, :greater_than => 0.0, :less_than_or_equal_to => 24.0
  validates_presence_of :user, :activity, :hour_type

  attr_protected :locked, :billed

  before_save :validate_changes_on_locked_entry
  
  def before_destroy
    if locked
      errors.add_to_base "Cannot delete locked hours"
      return false
    end
  end

  named_scope :on_day, lambda { |day|
    {  :conditions => ['date = ?', day ] }
  }

  named_scope :for_user, lambda { |user_id|
    { :conditions => { :user_id => user_id } }
  }

  named_scope :billed, lambda { |billed|
    { :conditions => { :billed => billed } }
  }

  named_scope :locked, lambda { |locked|
    { :conditions => { :locked => locked } }
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
      if value || t.billed == false
        t.locked = value
        t.save
      end
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

  private
  
  # Halt changes to locked time entries unless the dirty state
  # includes changes to the locked attribute itself or the billed status.
  def validate_changes_on_locked_entry
    if locked && !(changed.include?("locked") || changed.include?("billed"))
      errors.add_to_base("Editing of locked time entries is not allowed")
      return false
    end
  end
  
end
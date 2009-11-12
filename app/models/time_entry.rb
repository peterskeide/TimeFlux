class TimeEntry < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :activity
  belongs_to :hour_type

  has_and_belongs_to_many :tags
  
  OPEN = 0
  LOCKED = 1
  BILLED = 2

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
    user_id ? { :conditions => { :user_id => user_id } } : {}
  }

  named_scope :for_type, lambda { |hour_type_id|
    hour_type_id ? { :conditions => { :hour_type_id => hour_type_id } } : {}
  }

  named_scope :status, lambda { |status|
    status ? { :conditions => { :status => status } } : {}
  }

  named_scope :billed, lambda { |billed|
    if billed == nil then {}
    else
      { :conditions => { :status => billed ? BILLED : [OPEN,LOCKED] } }
    end
  }

  named_scope :locked, lambda { |locked|
    if locked == nil then {}
    else
      { :conditions =>  { :status => locked ? [LOCKED,BILLED] : OPEN } }
    end
  }

  named_scope :between, lambda { |*args|
    {  :conditions => { :date => (args.first..args.second) } }
  }

  named_scope :for_activity, lambda { |activity|
    activity ? {  :conditions =>  { :activity_id => activity } } : {}
  }

  named_scope :for_activities, lambda { |activities|
    activities ? {  :conditions =>  { :activity_id => activities } } : {}
  }

  named_scope :for_project, lambda { |project_id|
    project_id ? { :joins => :activity, :conditions => ["activities.project_id = ?", project_id] } : {}
  }

  named_scope :include_users, { :include => :user }

  named_scope :include_hour_types, { :include => :hour_type }

  # Combining the distinct scopes with between will not return the expected result
  # These are in general not really stable...
  named_scope :distinct_dates, :select => 'DISTINCT date'

  named_scope :distinct_activities, :select => 'DISTINCT activity_id'
  
  named_scope :distinct_types, :select => 'DISTINCT hour_type_id'
  
  def weekday
    Date::DAYNAMES[date.wday]
  end

  def locked
    status == LOCKED || status == BILLED
  end

  def billed
    status == BILLED
  end

  def status_str
    case status
    when   OPEN then "Open"
    when LOCKED then "Locked"
    when BILLED then "Billed"
    else "ERROR: status not set!"
    end
  end
  
  def self.search(from_day,to_day,customer,project,tag,tag_type,user,status)
    debug = ""

    time_entry_scope = TimeEntry.between(from_day, to_day).for_user(user).status(status)
      
    # Search Time entries for matches
    if customer || project || tag_type
      activity_scope = Activity.for_customer(customer).for_project(project)
      if tag
        activities = activity_scope.for_tag(tag)
      else
        activities = activity_scope.for_tag_type(tag_type)
      end
      time_entries = time_entry_scope.for_activities(activities)
    else
      time_entries = time_entry_scope
    end

    debug += "#{time_entries.size} Entries from #{activities ? activities.size : 'all'} activities"

    # Add explicidly tagged time entries to the result
    if tag_type || tag

      if tag
        tagged_entries = tag.time_entries.between(from_day, to_day).for_user(user).status(status)
        debug += "+  #{tagged_entries.size} Entries with Tag"
      else
        tagged_entries = []
        tag_type.tags.each do |the_tag|
          tagged_entries += the_tag.time_entries.between(from_day, to_day).for_user(user).status(status)
        end
        tagged_entries.uniq!
        debug += "+  #{tagged_entries.size} Entries with tags from category"
      end
    end

    logger.debug("Search results: #{debug}")
    
    tagged_entries ? (time_entries | tagged_entries) : time_entries
  end
  

  def self.mark_as_locked(time_entries, value=true)
    time_entries.each do |t|
      unless t.billed
        t = TimeEntry.find(t.id) if t.readonly?

        t.status = value ? TimeEntry::LOCKED : TimeEntry::OPEN
        t.save
      end
    end
  end

  # Billed time entries are always locked
  def self.mark_as_billed(time_entries, value=true)
    time_entries.each do |t|
      t = TimeEntry.find(t.id) if t.readonly?
      t.status = value ? TimeEntry::BILLED : TimeEntry::LOCKED
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
    if locked && !(changed.include?("status"))
      errors.add_to_base("Editing of locked time entries is not allowed")
      return false
    end
  end
  
end
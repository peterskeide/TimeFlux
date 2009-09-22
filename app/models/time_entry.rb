class TimeEntry < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :activity
  belongs_to :hour_type

  has_and_belongs_to_many :tags
  
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

  named_scope :billed, lambda { |billed|
    billed ? { :conditions => { :billed => billed } } : {}
  }

  named_scope :locked, lambda { |locked|
    locked ? { :conditions => { :locked => locked } } : {}
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
    project_id ? { :include => :activity, :conditions => ["activities.project_id = ?", project_id] } : {}
  }


  # Combining the distinct scopes with between will not return the expected result
  # These are in general not really stable...
  named_scope :distinct_dates, :select => 'DISTINCT date'

  named_scope :distinct_activities, :select => 'DISTINCT activity_id'
  
  named_scope :distinct_types, :select => 'DISTINCT hour_type_id'
  
  def weekday
    Date::DAYNAMES[date.wday]
  end
  
  def self.search(from_day,to_day,customer,project,tag,tag_type,user,billed)
    debug = ""

    # Search Time entries for matches
    if customer || project || tag_type
      if tag
        activities = Activity.for_tag(tag).for_customer(customer).for_project(project)
      else
        activities = Activity.for_tag_type(tag_type).for_customer(customer).for_project(project)
      end
      time_entries = TimeEntry.between(from_day, to_day).for_activities(activities).for_user(user).billed(billed)  
    else
      time_entries = TimeEntry.between(from_day, to_day).for_user(user).billed(billed)
    end

    debug += "#{time_entries.size} Entries from #{activities ? activities.size : 'all'} activities"

    # Add explicidly tagged time entries to the result
    if tag_type || tag

      if tag
        tagged_entries = tag.time_entries.between(from_day, to_day).for_user(user).billed(billed)
        debug += "+  #{tagged_entries.size} Entries with Tag"
      else
        tagged_entries = []
        tag_type.tags.each do |the_tag|
          tagged_entries += the_tag.time_entries.between(from_day, to_day).for_user(user).billed(billed)
        end
        tagged_entries.uniq!
        debug += "+  #{tagged_entries.size} Entries with tags from category"
      end
    end

    logger.debug(debug)
    puts debug
    tagged_entries ? (time_entries | tagged_entries) : time_entries
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
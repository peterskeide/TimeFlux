# Offers various convenience methods relevant for collections
# of TimeEntry instances.
class MonthReview::TimeEntryArray < DelegateClass(Array) 
  def initialize(time_entries)
    time_entries.each { |te| raise(ArgumentError, "#{self.class} can only contain instances of TimeEntry") unless te.class == TimeEntry }
    @time_entries = time_entries
    super(@time_entries)
  end

  # Returns the sum of the hours of all contained TimeEntry
  # instances.
  def sum_hours
    @time_entries.map { |te| te.hours }.sum
  end
  
  def sum_billable_hours
    self.billable.sum_hours
  end
  
  def sum_hours_on_date(date)
    self.for_date(date).sum_hours
  end
  
  def sum_hours_between(from_date, to_date)
    self.between(from_date, to_date).sum_hours
  end
  
  # Returns the total number of the days that have time entries based
  # on all contained TimeEntry instances.
  def sum_days
    @time_entries.map { |te| te.date }.uniq.length
  end
   
  # Like Array +, this method returns a new instance of
  # TimeEntryArray with the contents of the original + new array.
  def +(array)
    self.class.new(@time_entries + array)
  end
  
  # Like Array -, this method returns a new instance of
  # TimeEntryArray with the contents of the original - new array.
  def -(array)
    self.class.new(@time_entries - array)
  end
  
  # Returns *a new instance of TimeEntryArray* containing only
  # TimeEntry instances in the specified date interval.
  def between(from_date, to_date)
    self.class.new @time_entries.select { |te| te.date >= from_date && te.date <= to_date } 
  end
  
  # Returns *a new instance of TimeEntryArray* containing only
  # TimeEntry instances for the specified date.
  def for_date(date)
    self.class.new @time_entries.select { |te| date == te.date }
  end
  
  # Returns *a new instance of TimeEntryArray* containing only
  # TimeEntry instances that are billable.
  def billable
    self.class.new @time_entries.select { |te| te.billable? }
  end
  
  # Returns *a new instance of TimeEntryArray* containing only
  # TimeEntry instances that are locked.
  def locked
    self.class.new @time_entries.select { |te| te.locked }
  end
  
  # Returns *a new instance of TimeEntryArray* containing only
  # TimeEntry instances that belong to the specified activity.
  # The activity argument must be an instance of the Activity model.
  def for_activity(activity)
    self.class.new @time_entries.select { |te| activity == te.activity }
  end
  
  # Returns a unique and sorted list of activities the contained
  # TimeEntry instances belong to.
  def uniq_activities
    @time_entries.map { |te| te.activity }.uniq.sort
  end
end
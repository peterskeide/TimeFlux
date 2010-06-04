# Offers various convenience methods relevant for collections
# of TimeEntry instances.
# 
# TimeEntryEnumerable is primarily intended for reporting. Hence,
# all passed in TimeEntry instances will be marked readonly.
# This should remove any confusion that will otherwise appear
# if someone attempts to update a TimeEntry instance after one of its'
# values has been referenced by a method that support memoization. 
class MonthReview::TimeEntryEnumerable
  include Enumerable
  
  def initialize(time_entries)
    time_entries.each { |te| 
      raise "#{self.class} can only contain instances of TimeEntry" unless te.class == TimeEntry
      te.readonly! unless te.readonly?
      }
    @time_entries = time_entries
  end
  
  def each
    @time_entries.each { |te| yield te }
  end
  
  # Returns the sum of the hours of all contained TimEntry
  # instances. The calculated value is memoized.
  def sum_hours
    @sum_hours ||= @time_entries.map { |te| te.hours }.sum
  end
  
  # Returns the total number of the days that have time entries based
  # on all contained TimeEntry instances. The calculated value is memoized.
  def sum_days
    @sum_days ||= @time_entries.map { |te| te.date }.uniq.length
  end
  
  # Returns *a new instance of TimeEntryEnumerable* containing only
  # TimeEntry instances in the specified date interval.
  def between(from_date, to_date)
    self.class.new @time_entries.select { |te| te.date >= from_date && te.date <= to_date } 
  end
  
  # Returns *a new instance of TimeEntryEnumerable* containing only
  # TimeEntry instances for the specified date.
  def for_date(date)
    self.class.new @time_entries.select { |te| date == te.date }
  end
  
  # Returns *a new instance of TimeEntryEnumerable* containing only
  # TimeEntry instances that are billable. The returned value is memoized.
  def billable
    @billable_time_entries ||= self.class.new @time_entries.select { |te| te.billable? }
  end
  
  # Returns *a new instance of TimeEntryEnumerable* containing only
  # TimeEntry instances that belong to the specified activity.
  # The activity argument must be an instance of the Activity model.
  def for_activity(activity)
    self.class.new @time_entries.select { |te| activity == te.activity }
  end
  
  # Returns a unique and sorted list of activities the contained
  # TimeEntry instances belong to. The returned value is memoized. 
  def uniq_activities
    @uniq_activities ||= @time_entries.map { |te| te.activity }.uniq.sort
  end
end
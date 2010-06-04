class TimeEntryEnumerable
  include Enumerable
  
  def initialize(time_entries)
    time_entries.each { |te| raise "#{self.class} can only contain instances of TimeEntry" unless te.class == TimeEntry }
    @time_entries = time_entries
  end
  
  def each
    @time_entries.each { |te| yield te }
  end

  def sum_hours
    @sum_hours ||= @time_entries.map { |te| te.hours}.sum
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
  # TimeEntry instances that are billable.
  def billable
    self.class.new @billable ||= @time_entries.select { |te| te.billable? }
  end
  
  # Returns a unique and sorted list of activities the contained
  # TimeEntry instances belong to. 
  def activities
    @activities ||= @time_entries.map { |te| te.activity }.uniq.sort
  end
end
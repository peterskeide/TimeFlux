class MonthReviewFixtures
    
  # Returns a new instance of MonthReview::TimeEntryEnumerable with
  # time entries between options[:start_date] and options[:end_date].
  # There will be options[:per_day] entries for each date.
  #
  # No time entries will be generated for a date where date.work_hours
  # returns 0.0.
  def self.time_entry_array(options = {}) 
    time_entries = []
    start_date = options[:start_date]
    end_date = options[:end_date]
    time_entries_per_day = options[:per_day].to_i   
    (start_date..end_date).to_a.each do |date|
      unless 0.0 == date.work_hours
        time_entries_per_day.times { |i| time_entries << Factory.create(:billable_time_entry, :date => date, :hours => 7.5) }
      end      
    end
    MonthReview::TimeEntryArray.new(time_entries)
  end
  
  def self.create_n_time_entries_per_date(entries_per_date, date_or_array, options = {})
    time_entries = []
    if date_or_array.is_a?(Date)
      options = options.merge({ :date => date_or_array })
      entries_per_date.times { time_entries << Factory.build(:billable_time_entry, options) }
    elsif date_or_array.is_a?(Array)
      date_or_array.each do |date|
        options = options.merge({ :date => date })
        entries_per_date.times { time_entries << Factory.build(:billable_time_entry, options) }
      end
    else
      raise ArgumentError, "An instance of date or an array of dates expected, but got #{date_or_array.class}"
    end
    time_entries
  end
end
class MonthReviewFixtures
    
  # Returns a new instance of MonthReview::TimeEntryEnumerable with
  # time entries between options[:start_date] and options[:end_date].
  # There will be options[:per_day] entries for each date.
  #
  # No time entries will be generated for a date where date.work_hours
  # returns 0.0.
  def self.time_entry_enumerable(options = {}) 
    time_entries = []
    start_date = options[:start_date]
    end_date = options[:end_date]
    time_entries_per_day = options[:per_day]   
    (start_date..end_date).to_a.each do |date|
      unless 0.0 == date.work_hours
        if time_entries_per_day.is_a?(Fixnum)
          time_entries_per_day.times { |i| time_entries << Factory.create(:time_entry, :date => date, :hours => 7.5) }
        elsif time_entries_per_day.is_a?(Proc)
          time_entries_per_day.call(date, time_entries)
        else
          raise "Unknow format for :per_day option"
        end
      end      
    end
    MonthReview::TimeEntryEnumerable.new(time_entries)
  end
end
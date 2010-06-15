require 'test_helper'

class TimeEntryArrayTest < ActiveSupport::TestCase
  
  def create_n_time_entries_per_date(entries_per_date, date_array)
    time_entries = []
    date_array.each do |date|
      entries_per_date.times do
        time_entries << Factory.build(:billable_time_entry, :hours => 7.5, :date => date)
      end
    end
    time_entries
  end
  
  context "An instance of MonthReview::TimeEntryArray" do
    setup do   
      today = Date.today
      @weekdays = (today.beginning_of_week..today.end_of_week).to_a
      @time_entries = create_n_time_entries_per_date(3, @weekdays)
      @array = MonthReview::TimeEntryArray.new(@time_entries)
    end
    
    should "report an error if the given array contains an object that is not of type TimeEntry" do
      entries = @time_entries + ["Foo"]
      assert_raise(ArgumentError) { MonthReview::TimeEntryArray.new(entries) }
    end
    
    should "return the sum of the hours of all contained time entries" do
      expected_sum = (3 * 7.5) * @weekdays.length
      assert_equal(expected_sum, @array.sum_hours)
    end
    
    should "return the total number of days for which there are time entries" do
      expected_number_of_days = @weekdays.length
      assert_equal(expected_number_of_days, @array.sum_days)
    end
    
    should "return the total number of hours for a given date" do
      expected_hours = 3 * 7.5
      assert_equal(expected_hours, @array.sum_hours_on_date(@weekdays.first))
      
      @array << Factory.build(:billable_time_entry, :hours => 7.5, :date => @weekdays.first) # Add another entry and check if the sum changes
      expected_hours = 4 * 7.5
      assert_equal(expected_hours, @array.sum_hours_on_date(@weekdays.first))
      
      @array << Factory.build(:billable_time_entry, :hours => 7.5, :date => @weekdays[3]) # Add another entry to a different day
      assert_equal(expected_hours, @array.sum_hours_on_date(@weekdays[3]))
    end
    
    should "return the total number of hours for a given date range" do
      expected_hours = (3 * 7.5) * 3 # We're going to ask for a range of 3 days
      assert_equal(expected_hours, @array.sum_hours_between(@weekdays[1], @weekdays[3]))
    end
    
    should "return the total number of hours for all billable time entries" do
      total_hours = @array.sum_hours # the array initially only contains billable time entries (see setup)
      3.times { @array << Factory.build(:unbillable_time_entry, :hours => 7.5) }
      assert_equal(total_hours, @array.sum_billable_hours)
    end
    
    should "return all time entries that are locked" do
      locked_entries = []
      3.times { locked_entries << Factory.build(:billable_time_entry, :hours => 7.5, :status => TimeEntry::LOCKED) }
      @array += locked_entries
      result = @array.locked
      assert_equal(locked_entries.length, result.length)
      result.each { |result| 
        assert_true(locked_entries.include?(result)) 
      }
    end
  end
end
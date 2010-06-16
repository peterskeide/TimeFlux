require 'test_helper'
require "#{File.dirname(__FILE__)}/fixtures"

class TimeEntryArrayTest < ActiveSupport::TestCase
    
  context "An instance of MonthReview::TimeEntryArray" do
    setup do   
      today = Date.today
      @weekdays = (today.beginning_of_week..today.end_of_week).to_a
      @time_entries = MonthReviewFixtures.create_n_time_entries_per_date(3, @weekdays)
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
    
    should "return all time entries that are billable" do
      original_length = @time_entries.length
      5.times { @array << Factory.build(:unbillable_time_entry) }
      billable = @array.billable
      assert_equal(original_length, billable.length)
      billable.each do |b|
        assert_true(b.billable?)
      end
    end
    
    should "return all time entries between (and including) a given from and to date" do
      monday = @weekdays[1]
      wednesday = @weekdays[3]
      assert_equal(9, @array.between(monday, wednesday).length) # Setup creates 3 time entries per day.
    end
    
    should "return all time entries that belong to a given activity" do
      activity = Factory.create(:billable_activity, :name => "Make more money")
      5.times { @array << Factory.build(:unbillable_time_entry, :activity => activity) }
      result = @array.for_activity(activity)
      assert_equal(5, result.length)
      result.each do |time_entry|
        assert_equal(activity, time_entry.activity)
      end
    end
    
    should "return the activities of all the time entries excluding duplicates" do
      design = Factory.create(:billable_activity, :name => "Design component")
      implement = Factory.create(:billable_activity, :name => "Implement")
      qa = Factory.create(:billable_activity, :name => "QA")
      
      design_time_entries = MonthReviewFixtures.create_n_time_entries_per_date(1, @weekdays, :activity => design)
      implement_time_entries = MonthReviewFixtures.create_n_time_entries_per_date(1, @weekdays, :activity => implement)
      qa_time_entries = MonthReviewFixtures.create_n_time_entries_per_date(1, @weekdays, :activity => qa)
      
      @array.clear
      @array += (design_time_entries + implement_time_entries + qa_time_entries)
      
      uniq_activities = @array.uniq_activities
      assert_equal(3, uniq_activities.length)
      [design, implement, qa].each do |a|
        assert_true(uniq_activities.include?(a))
      end
    end
        
    should "report an error if an attempt is made to add an object that is not an instance of TimeEntry" do
      assert_raise(ArgumentError) { @array << "foobar" }
      assert_raise(ArgumentError) { @array[0] = "foobar" }
    end
    
    should "add an instance of TimeEntry to the contained array of time entries" do
      new_entry = Factory.build(:billable_time_entry)
      @array << new_entry
      assert_true(@array.include?(new_entry))
      
      another_entry = Factory.build(:billable_time_entry)
      @array[3] = another_entry
      assert_same(another_entry, @array[3])
    end
    
    should "report an error if an attempt is made to add an array that contains instances of classes other than TimeEntry" do
      objects = MonthReviewFixtures.create_n_time_entries_per_date(3, Date.today)
      objects += ["illegal", 3, :key]
      assert_raise(ArgumentError) { @array + objects }
    end
    
    should "return a new instance of MonthReview::TimeEntryArray that contains new and old entries when a collection of time entries is added" do
      new_entries = MonthReviewFixtures.create_n_time_entries_per_date(4, Date.today)
      result = @array + new_entries
      assert_instance_of(MonthReview::TimeEntryArray, result)
      assert_not_same(@array, result)
      new_entries.each do |e|
        assert_true(result.include?(e))
        assert_false(@array.include?(e))
      end
      @array.each do |e|
        assert_true(result.include?(e))
      end
    end
    
    should "return a new instance of MonthReview::TimeEntryArray containing old entries minus the given array of time entries" do
      entries = @array[0..5]
      result = @array - entries
      assert_instance_of(MonthReview::TimeEntryArray, result)
      assert_not_same(@array, result)
      assert_equal(@array.length - entries.length, result.length)
      entries.each do |e|
        assert_false(result.include?(e))
        assert_true(@array.include?(e))
      end
    end
    
    should "return the underlying array of time entries" do
      assert_same(@time_entries, @array.to_a)
    end
    
    should "return a new instance of MonthReview::TimeEntryArray containing the original time entries * <arg>" do
      expected_length = @array.length * 3
      result = @array * ", "
      assert_instance_of(String, result)
      assert_equal(@time_entries.join(", "), result)
      result = @array * 3
      assert_instance_of(MonthReview::TimeEntryArray, result)
      assert_equal(expected_length, result.length)
    end
  end
end
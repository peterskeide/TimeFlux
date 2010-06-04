require 'test_helper'

class CalendarTest < ActiveSupport::TestCase
      
  context "For an instance of MonthReview::Calendar" do
    setup do
      today = Date.today
      @time_entries = []
      7.times { |i| @time_entries << Factory.create(:time_entry, :date => (today + i)) }
      @time_entry_enumerable = MonthReview::TimeEntryEnumerable.new(@time_entries)
      @month_start = today.beginning_of_month
      @month_end = today.end_of_month
      @calendar = MonthReview::Calendar.new(@time_entry_enumerable, @month_start, @month_end)
    end
    
    context "days" do
      should "return an instance of MonthReview::Calendar::Day per day in the month including all days from the first and last week of the month" do
        expected_dates = (@month_start.beginning_of_week..@month_end.end_of_week).to_a
        @calendar.days.each do |day|
          assert_equal(MonthReview::Calendar::Day, day.class)
          assert_equal(expected_dates.shift, day.date)
        end
      end
    end
    
    context "weeks" do
      should "return an instance of MonthReview::Calendar::Week per week in the month" do
        expected_weeks = (@month_start.cweek..@month_end.cweek).to_a
        @calendar.weeks.each do |week|
          assert_equal(MonthReview::Calendar::Week, week.class)
          assert_equal(expected_weeks.shift, week.number)
        end 
      end    
    end
    
    context "month_name" do
      should "return the name of the month of the calendar" do
        assert_equal(Date::MONTHNAMES[@month_start.month], @calendar.month_name)
      end
    end
  end
  
  context "An instance of MonthReview::Calendar::Day" do
    setup do
      @today = Date.today
      @time_entries = []
      3.times { |i| @time_entries << Factory.create(:time_entry, :date => @today, :hours => 7.5) }
      @time_entry_enumerable = MonthReview::TimeEntryEnumerable.new(@time_entries)
      @day = MonthReview::Calendar::Day.new(@today, @time_entry_enumerable, true)
    end
    
    should "return true if it has a date that is equal to today" do
      assert_true(@day.today?)
    end
    
    should "return false if it has a date that is not equal to today" do
      @day = MonthReview::Calendar::Day.new(@today - 1, @time_entry_enumerable, true)
      assert_false(@day.today?)
    end
    
    should "return true if it represents a day in the current month" do
      assert_true(@day.in_reported_month?)
    end
    
    should "return false if it represents a day outside the current month" do
      @day = MonthReview::Calendar::Day.new(@today, @time_entry_enumerable, false)
      assert_false(@day.in_reported_month?)
    end
    
    should "return the sum of all the time entries it encapsulates" do
       assert_equal(22.5, @day.sum_hours)
    end
    
    should "return true if it has any reported hours" do
       assert_true(@day.hours_reported?)
    end
    
  end 
       
end
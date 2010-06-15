require 'test_helper'
require "#{File.dirname(__FILE__)}/fixtures"

class CalendarTest < ActiveSupport::TestCase
      
  context "For an instance of MonthReview::Calendar" do
    setup do
      today = Date.today
      @month_start = today.beginning_of_month
      @month_end = today.end_of_month
      time_entry_array = MonthReviewFixtures.time_entry_array(:start_date => @month_start, :end_date => @month_end, :per_day => 1)
      @calendar = MonthReview::Calendar.new(time_entry_array, @month_start, @month_end)
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
      @time_entry_array = MonthReviewFixtures.time_entry_array(:start_date => @today, :end_date => @today, :per_day => 3)
      @day = MonthReview::Calendar::Day.new(@today, @time_entry_array, true)
    end
    
    should "return true if it has a date that is equal to today" do
      assert_true(@day.today?)
    end
    
    should "return false if it has a date that is not equal to today" do
      @day = MonthReview::Calendar::Day.new(@today - 1, @time_entry_array, true)
      assert_false(@day.today?)
    end
    
    should "return true if it represents a day in the current month" do
      assert_true(@day.in_reported_month?)
    end
    
    # Regarding days outside the month of the calendar: The calendar
    # includes all the days of the first and last weeks of the month, even
    # if they technically belong to the previous and/or next month.
    should "return false if it represents a day outside the current month" do
      @day = MonthReview::Calendar::Day.new(@today, @time_entry_array, false)
      assert_false(@day.in_reported_month?)
    end
    
    should "return the sum of all the time entries it encapsulates" do
       assert_equal(22.5, @day.sum_hours)
    end
    
    should "return true if it has any reported hours" do
       assert_true(@day.hours_reported?)
    end    
  end
  
  context "An instance of MonthReview::Calendar::Week" do
     setup do
       @today = Date.today
       @weekdays = []
       (@today.beginning_of_week..@today.end_of_week).to_a.each do |date|
         time_entry_array = MonthReviewFixtures.time_entry_array(:start_date => date, :end_date => date, :per_day => 3)
         @weekdays << MonthReview::Calendar::Day.new(date, time_entry_array, true)
       end
       @week = MonthReview::Calendar::Week.new(@today.cweek, @weekdays) 
      end
      
      should "return the week number" do
        assert_equal(@today.cweek, @week.number)
      end
      
      should "return the date of the first day of the week" do
        assert_equal(@today.beginning_of_week, @week.start_date)
      end
      
      should "return the sum total hours of all the contained time entries" do
        expected_sum = @weekdays.map { |wd| wd.sum_hours }.sum
        assert_equal(expected_sum, @week.sum_hours)
      end
      
      should "return one instance of MonthReview::Calendar::Day per day of the week" do
        expected_days = (@today.beginning_of_week..@today.end_of_week).to_a
        @week.days.each do |day|
          assert_equal(MonthReview::Calendar::Day, day.class)
          assert_equal(expected_days.shift, day.date)
        end
      end
  end      
end
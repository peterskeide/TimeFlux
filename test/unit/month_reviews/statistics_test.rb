require 'test_helper'
require "#{File.dirname(__FILE__)}/fixtures.rb"

class StatisticsTest < ActiveSupport::TestCase
    
  context "An instance of MonthReview::Statistics for the current month" do
    setup do
      @today = Date.today
      @month_start = @today.beginning_of_month
      @month_end = @today.end_of_month 
      @time_entry_enumerable = mock
      @statistics = MonthReview::Statistics.new(@time_entry_enumerable, @month_start, @month_end, @today)
    end

    should "calculate billing degree" do     
      @time_entry_enumerable.expects(:sum_billable_hours).returns(160)
      WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @month_end).returns(160)
      assert_equal(100, @statistics.billing_degree)
      
      @time_entry_enumerable.expects(:sum_billable_hours).returns(180)
      WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @month_end).returns(90)
      assert_equal(200, @statistics.billing_degree)
      
      @time_entry_enumerable.expects(:sum_billable_hours).returns(25)
      WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @month_end).returns(50)
      assert_equal(50, @statistics.billing_degree)
      
      @time_entry_enumerable.expects(:sum_billable_hours).returns(0)
      assert_equal(0, @statistics.billing_degree)    
    end
    
    should "return registered hours" do
      @time_entry_enumerable.expects(:sum_hours).returns(140)
      assert_equal(140, @statistics.registered_hours)
    end
    
    should "return expected hours" do
      WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @month_end).returns(160)
      assert_equal(160, @statistics.expected_hours) 
    end
    
    should "return expected days" do
      WorkTimeCalculations.expects(:find_expected_workdays_between).with(@month_start, @month_end).returns(22)
      assert_equal(22, @statistics.expected_days)
    end
    
    should "return registered days" do
      @time_entry_enumerable.expects(:sum_days).returns(22)
      assert_equal(22, @statistics.registered_days)
    end
    
    should "report if statistics are available" do
      @time_entry_enumerable.expects(:empty?).returns(true)
      assert_false(@statistics.available?)
      
      @time_entry_enumerable.expects(:empty?).returns(false)
      assert_true(@statistics.available?)
    end
    
    context "with no time entries registered today" do
      setup do
        @yesterday = @today - 1
        @time_entry_enumerable.expects(:sum_hours_on_date).at_least_once.with(@today).returns(0)
      end
      
      should "calculate balance based on registered vs expected hours from the first day of the month up to and including yesterday" do
        @time_entry_enumerable.expects(:sum_hours_between).with(@month_start, @yesterday).returns(50)
        WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @yesterday).returns(50)
        assert_equal(0, @statistics.balance)
        
        @time_entry_enumerable.expects(:sum_hours_between).with(@month_start, @yesterday).returns(20.2)
        WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @yesterday).returns(40.7)
        assert_in_delta(-20.5, @statistics.balance, 0.01)

        @time_entry_enumerable.expects(:sum_hours_between).with(@month_start, @yesterday).returns(160)        
        WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @yesterday).returns(150)
        assert_equal(10, @statistics.balance)
      end
    end
    
    context "with time entries registered today" do
      setup do
        @time_entry_enumerable.expects(:sum_hours_on_date).at_least_once.with(@today).returns(7.5)
      end
      
      should "calculate balance based on registered vs expected hours from the first day of the month up to and including today" do
        @time_entry_enumerable.expects(:sum_hours_between).with(@month_start, @today).returns(0.1)
        WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @today).returns(150)
        assert_equal(-149.9, @statistics.balance)
        
        @time_entry_enumerable.expects(:sum_hours_between).with(@month_start, @today).returns(160.1)
        WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @today).returns(160)
        assert_in_delta(0.1, @statistics.balance, 0.01)

        @time_entry_enumerable.expects(:sum_hours_between).with(@month_start, @today).returns(140.5)        
        WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @today).returns(160.5)
        assert_equal(-20, @statistics.balance)
      end
    end 
  end
    
  context "An instance of MonthReview::Statistics for a month in the past" do
    setup do
      @today = Date.today
      @month_start = @today.prev_month.beginning_of_month
      @month_end = @today.prev_month.end_of_month 
      @time_entry_enumerable = mock
      @statistics = MonthReview::Statistics.new(@time_entry_enumerable, @month_start, @month_end, @today)
    end
      
    should "calculate balance based on registered vs expected hours for the whole month" do      
       @time_entry_enumerable.expects(:sum_hours).returns(140)
       WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @month_end).returns(160)
       assert_equal(-20, @statistics.balance)
     
       @time_entry_enumerable.expects(:sum_hours).returns(150)
       WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @month_end).returns(150)
       assert_equal(0, @statistics.balance)
     
       @time_entry_enumerable.expects(:sum_hours).returns(157.5)
       WorkTimeCalculations.expects(:find_expected_workhours_between).with(@month_start, @month_end).returns(150)
       assert_equal(7.5, @statistics.balance)
    end
  end
  
  context "An instance of MonthReview::Statistics for a month in the future" do
    setup do
      @today = Date.today
      @month_start = @today.next_month.beginning_of_month
      @month_end = @today.next_month.end_of_month 
      @time_entry_enumerable = mock
      @statistics = MonthReview::Statistics.new(@time_entry_enumerable, @month_start, @month_end, @today)
    end
      
    should "not calculate balance" do      
       assert_equal(0, @statistics.balance)
    end
  end
    
end
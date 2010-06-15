require 'test_helper'

class ActivitySummaryTest < ActiveSupport::TestCase
     
  context "An instance of MonthReview::ActitivySummary" do
    setup do
      today = Date.today
      @days_of_month = (today.beginning_of_month..today.end_of_month).to_a
      
      @time_entries = []
      @unbillable_time_entries = []
     
      @days_of_month.each do |date|
        @time_entries << Factory.create(:billable_time_entry, :date => date)
        @unbillable_time_entries << Factory.create(:unbillable_time_entry, :date => date)
      end
      
      time_entry_array = MonthReview::TimeEntryArray.new(@time_entries + @unbillable_time_entries)
      @activity_summary = MonthReview::ActivitySummary.new(time_entry_array)
    end
    
    should "return summary of activities for all billable time entries" do
      billable = @activity_summary.billable
      customer_names = customer_names_from_array(@time_entries)
      assert_equal(customer_names.length, billable.length)
      billable.each do |b|
        assert_true(customer_names.include?(b[:name]))
        assert_equal(7.5, b[:hours]) 
      end
    end
    
    should "return summary of activities for all unbillable time entries" do
      unbillable = @activity_summary.unbillable
      customer_names = customer_names_from_array(@unbillable_time_entries)
      assert_equal(customer_names.length, unbillable.length)
      unbillable.each do |b|
        assert_true(customer_names.include?(b[:name]))
        assert_equal(7.5, b[:hours]) 
      end
    end
  end
  
  def customer_names_from_array(time_entries)
    time_entries.collect { |te| te.activity.customer_project_name }.uniq
  end
  
end
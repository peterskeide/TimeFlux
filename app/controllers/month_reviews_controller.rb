class MonthReviewsController < ApplicationController  
  before_filter :check_authentication, :check_parent_user
  
  def show
    @user = User.find(params[:user_id])
    @month_start = parse_or_create_date
    @month_end = @month_start.end_of_month
    
    time_entry_array_incl_adjoining_weeks = find_time_entries_for_start_and_end_date_incl_adjoining_weeks  
    @calendar = MonthReview::Calendar.new(time_entry_array_incl_adjoining_weeks, @month_start, @month_end)
    
    time_entry_array_excl_adjoining_weeks = time_entry_array_incl_adjoining_weeks.between(@month_start, @month_end)    
    @activity_summary = MonthReview::ActivitySummary.new(time_entry_array_excl_adjoining_weeks)
    @statistics = MonthReview::Statistics.new(time_entry_array_excl_adjoining_weeks, @month_start, @month_end, Time.zone.now.to_date)
    
    @locked = time_entries_locked?(time_entry_array_excl_adjoining_weeks)
    @ready_for_approval = ((@statistics.registered_hours >= @statistics.expected_hours) && (@statistics.registered_days >= @statistics.expected_days))
  end
  
  private
  
  def find_time_entries_for_start_and_end_date_incl_adjoining_weeks
    first_day_of_first_week_of_month = @month_start.beginning_of_week
    last_day_of_last_week_of_month = @month_end.end_of_week
    time_entries = @user.time_entries.between(first_day_of_first_week_of_month, last_day_of_last_week_of_month).all(:order => "date ASC")
    MonthReview::TimeEntryArray.new(time_entries)
  end
  
  def time_entries_locked?(time_entry_array_excl_adjoining_weeks)
    time_entry_array_excl_adjoining_weeks.length == time_entry_array_excl_adjoining_weeks.locked.length
  end
end
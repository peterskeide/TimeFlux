class MonthReviewsController < ApplicationController  
  before_filter :check_authentication, :check_parent_user
  
  def show
    @user = User.find(params[:user_id])
    @month_start = parse_or_create_date
    @month_end = @month_start.end_of_month
    first_day_of_first_week_of_month = @month_start.beginning_of_week
    last_day_of_last_week_of_month = @month_end.end_of_week
    time_entries_incl_adjoining_weeks = @user.time_entries.between(first_day_of_first_week_of_month, last_day_of_last_week_of_month).all(:order => "date ASC")
    timeentryarray_incl_adjoining_weeks = MonthReview::TimeEntryArray.new(time_entries_incl_adjoining_weeks)
    @calendar = MonthReview::Calendar.new(timeentryarray_incl_adjoining_weeks, @month_start, @month_end)
    timeentryarray_excl_adjoining_weeks = timeentryarray_incl_adjoining_weeks.between(@month_start, @month_end)    
    @activity_summary = MonthReview::ActivitySummary.new(timeentryarray_excl_adjoining_weeks)
    today = Time.zone.now.to_date
    @statistics = MonthReview::Statistics.new(timeentryarray_excl_adjoining_weeks, @month_start, @month_end, today)
    @period = Period.new(@user, @month_start.year, @month_start.month)
  end  
end
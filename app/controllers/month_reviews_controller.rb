class MonthReviewsController < ApplicationController
  
  before_filter :check_authentication
  
  def show
    @user = User.find(params[:user_id])
    if params[:calendar]
      @beginning_of_month = Date.new(params[:calendar]["date(1i)"].to_i, params[:calendar]["date(2i)"].to_i, 1)
    else
      @beginning_of_month = Date.today.beginning_of_month    
    end
    @end_of_month = @beginning_of_month.end_of_month
    if params[:id] == "calendar"
      load_calendar_report_data
    elsif params[:id] == "listing"
      load_listing_report_data
    end
  end
  
  private
    
  def load_calendar_report_data
    @time_entries = @user.time_entries.between(@beginning_of_month, @end_of_month)
    @expected_hours = Holiday.expected_hours_between(@beginning_of_month, @end_of_month)
    @activities_summary = create_activity_summary
    respond_to do |format|
      format.html { render :template => "month_reviews/calendar.html.erb" }
    end
  end
  
  def create_activity_summary
    puts @time_entries.inspect
    activities = @time_entries.flatten.map { |te| te.activity }.uniq
    activities.collect do |activity|
      { :name => activity.name,
        :hours => activity.time_entries.for_user(@user).between(@beginning_of_month, @end_of_month).sum(:hours) }
    end
  end
    
  def load_listing_report_data
    @time_entries = @user.time_entries.between(@beginning_of_month, @end_of_month).group_by(&:activity)
    respond_to do |format|
      format.html { render :template => "month_reviews/listing.html.erb" }
      format.pdf { render :template => "month_reviews/listing.pdf.prawn" }
    end
  end
  
end
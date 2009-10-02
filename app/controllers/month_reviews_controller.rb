class MonthReviewsController < ApplicationController
  
  before_filter :check_authentication, :check_parent_user
  
  def show
    @user = User.find(params[:user_id])
    @beginning_of_month = parse_or_create_date
    if params[:id] == "calendar"
      load_calendar_report_data
    elsif params[:id] == "listing"
      load_listing_report_data
    end
  end
  
  private
    
  def load_calendar_report_data
    @period = Period.new(@user, @beginning_of_month.year, @beginning_of_month.month)
    @activities_summary = create_activity_summary(@user, @period)
    respond_to do |format|
      format.html { render :template => "month_reviews/calendar.html.erb" }
    end
  end
  
  def create_activity_summary(user,period)
    period.activities.sort.collect do |activity|
      { :name => activity.customer_project_name(50),
        :hours => activity.time_entries.for_user(user).between(period.start, period.end).sum(:hours) }
    end
  end
    
  def load_listing_report_data    
    @end_of_month = @beginning_of_month.end_of_month
    @time_entries = @user.time_entries.between(@beginning_of_month, @end_of_month).group_by(&:activity)
    respond_to do |format|
      format.html { render :template => "month_reviews/listing.html.erb" }
      format.pdf { render :template => "month_reviews/listing.pdf.prawn" }
    end
  end
  
  def parse_or_create_date
    if date = params[:calendar]
      if date.is_a?(String)
        return Date.parse(date)
      else
        return Date.new(params[:calendar]["date(1i)"].to_i, params[:calendar]["date(2i)"].to_i, 1)
      end
    else
      return Date.today.beginning_of_month    
    end
  end

end